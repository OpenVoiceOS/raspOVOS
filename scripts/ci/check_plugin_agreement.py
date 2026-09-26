#!/usr/bin/env python3
"""Every plugin a tier's configuration names must be installed by that tier's build.

`ovos-config autoconfigure` writes an `stt` and a `tts` module into
`mycroft.conf`. Those are entry-point names. A build installs distributions.
When the two disagree, the image boots with a configuration that points at a
plugin it does not carry, and nothing in the build or in CI says so: the
install succeeds, the image is produced, and the device is mute.

The check that used to be proposed for this compared line numbers -- whether a
`uv pip install` ran below the `autoconfigure` line. That is the wrong
invariant. autoconfigure's mapping is static: it writes the same modules
whether or not any plugin is installed, so the order does not matter and the
agreement does. This compares the two sets instead.

The known set is recorded in a baseline file rather than asserted away. The
check fails when the set gains a member, and it also fails when a member is
fixed and left in the baseline, so the baseline cannot rot into a list of
things nobody looks at. An empty baseline is the goal, not the starting point.

Usage:
    scripts/ci/check_plugin_agreement.py [--constraints URL_OR_PATH]
                                         [--baseline PATH]

Exit 0 when the findings are exactly the baseline, 1 when they are not,
2 when the check could not run. A check that cannot run never reports success.
"""
import argparse
import json
import os
import re
import subprocess
import sys
import tempfile

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# A tier's language scripts, and the autoconfigure flag that tier passes.
TIERS = {"lite": "--online", "hybrid": "--hybrid", "offline": "--offline"}

# The base image each tier is built on, and the script that produces it. What
# the base installs is available to every language script that runs on it.
BASE = {"lite": "build_raspOVOS_base_lite.sh",
        "hybrid": "build_raspOVOS_base_lite.sh",
        "offline": "build_raspOVOS_base_full.sh"}

# An entry-point name is not a distribution name. This is the known set; a
# plugin whose entry point differs from its distribution belongs here.
DISTRIBUTION = {"ovos-tts-plugin-phoonnx": "phoonnx"}

DEFAULT_CONSTRAINTS = ("https://github.com/OpenVoiceOS/OpenVoiceOS/raw/"
                       "refs/heads/main/constraints-alpha.txt")

DEFAULT_BASELINE = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                "plugin_agreement_baseline.txt")


def fail(message):
    print(f"ERROR: {message}", file=sys.stderr)
    sys.exit(2)


def read(path):
    full = os.path.join(REPO, path)
    if not os.path.exists(full):
        return None
    with open(full, encoding="utf-8") as handle:
        return handle.read()


def language_tag(script_source, lang):
    """The tag the script itself passes, never one this check invents."""
    match = re.search(r"autoconfigure[^\n]*--lang\s+([A-Za-z-]+)", script_source)
    return match.group(1) if match else None


def chain(tier, lang):
    """The scripts a build of this tier runs, base first.

    An offline script runs its hybrid counterpart, which runs its lite one, so
    a plugin installed by any of them is on the image.
    """
    scripts, seen = [], set()

    def walk(path):
        if path in seen:
            return
        source = read(path)
        if source is None:
            return
        seen.add(path)
        nested = re.search(r"lang_builds/(\w+)/build_raspOVOS_(\w+)\.sh", source)
        if nested:
            walk(f"lang_builds/{nested.group(1)}/build_raspOVOS_{nested.group(2)}.sh")
        scripts.append((path, source))

    walk(f"lang_builds/{tier}/build_raspOVOS_{lang}.sh")
    return scripts


def install_tokens(source):
    """The requirement strings a script installs, extras kept.

    Extras matter: `ovos-dinkum-listener[extras]` is what carries the plugins,
    and dropping the bracket is how a resolution loses them and this check
    reports findings that are its own.
    """
    tokens = set()
    for line in source.splitlines():
        match = re.match(r"\s*uv pip install\s+(.*)", line)
        if not match:
            continue
        for token in match.group(1).split():
            if token.startswith(("-", "$", "/")) or token == "install":
                continue
            if re.match(r"^[A-Za-z][A-Za-z0-9._-]*(\[[A-Za-z0-9,._-]+\])?"
                        r"([=<>!~].*)?$", token):
                tokens.add(token)
    return tokens


def installed_names(source):
    """Distribution names a script installs, read off its uv pip install lines."""
    return {re.split(r"[\[=<>;!~]", t)[0].lower() for t in install_tokens(source)}


def base_closure(tier, constraints):
    """Everything the base image resolves to, not only what it names.

    The base installs `ovos-dinkum-listener[extras]`, and that extra carries
    plugins. Reading the install lines alone reports those as missing, which
    is an instrument gap that would bury the real findings.
    """
    source = read(BASE[tier])
    if source is None:
        fail(f"base script not found: {BASE[tier]}")
    requirements = sorted(install_tokens(source))
    with tempfile.TemporaryDirectory() as work:
        req = os.path.join(work, "requirements.in")
        with open(req, "w", encoding="utf-8") as handle:
            handle.write("\n".join(requirements) + "\n")
        command = ["uv", "pip", "compile", "--prerelease=allow",
                   "-c", constraints, req, "-o", os.path.join(work, "out.txt"),
                   "--quiet"]
        done = subprocess.run(command, capture_output=True, text=True)
        if done.returncode != 0:
            fail("could not resolve the base image's install set, so the "
                 "check cannot run:\n" + (done.stderr or "").strip()[:800])
        with open(os.path.join(work, "out.txt"), encoding="utf-8") as handle:
            resolved = handle.read()
    names = {line.split("==")[0].strip().lower()
             for line in resolved.splitlines()
             if line and not line.startswith(("#", " ", "-"))}
    return names | installed_names(source)


def selection(tier, tag):
    """What autoconfigure writes for this tier and tag. Run, never guessed."""
    with tempfile.TemporaryDirectory() as home:
        env = dict(os.environ, XDG_CONFIG_HOME=home, HOME=home)
        done = subprocess.run(
            ["ovos-config", "autoconfigure", "--lang", tag, TIERS[tier],
             "--male", "--platform", "rpi4"],
            env=env, capture_output=True, text=True)
        config = os.path.join(home, "mycroft", "mycroft.conf")
        if not os.path.exists(config):
            fail(f"autoconfigure wrote no config for {tier} {tag}; the check "
                 f"cannot run:\n{(done.stderr or '').strip()[:400]}")
        with open(config, encoding="utf-8") as handle:
            written = json.load(handle)
    return ((written.get("stt") or {}).get("module"),
            (written.get("tts") or {}).get("module"))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--constraints", default=DEFAULT_CONSTRAINTS)
    parser.add_argument("--baseline", default=DEFAULT_BASELINE)
    args = parser.parse_args()

    try:
        probe = subprocess.run(["ovos-config", "--help"], capture_output=True)
    except FileNotFoundError:
        fail("ovos-config is not on PATH, so nothing can be measured. This is "
             "not a clean result: the check did not run.")
    if probe.returncode != 0:
        fail("ovos-config is present but does not run, so nothing can be "
             "measured. This is not a clean result: the check did not run.")

    closures = {tier: base_closure(tier, args.constraints) for tier in TIERS}

    checked, missing, skipped = 0, [], []
    for tier in TIERS:
        directory = os.path.join(REPO, "lang_builds", tier)
        if not os.path.isdir(directory):
            continue
        for name in sorted(os.listdir(directory)):
            match = re.fullmatch(r"build_raspOVOS_(\w+)\.sh", name)
            if not match:
                continue
            lang = match.group(1)
            path = f"lang_builds/{tier}/{name}"
            source = read(path)
            tag = language_tag(source, lang)
            if tag is None:
                # No autoconfigure line: the script chooses nothing, so there
                # is nothing to disagree with. Reported, never silent.
                skipped.append(f"{path} (no autoconfigure --lang line)")
                continue
            installed = set(closures[tier])
            for _, text in chain(tier, lang):
                installed |= installed_names(text)
            stt, tts = selection(tier, tag)
            for role, entry_point in (("stt", stt), ("tts", tts)):
                checked += 1
                if not entry_point:
                    continue
                distribution = DISTRIBUTION.get(entry_point, entry_point).lower()
                if distribution not in installed:
                    missing.append((tier, lang, tag, role, entry_point,
                                    distribution))

    print(f"checked {checked} selections across {len(TIERS)} tiers")
    for line in skipped:
        print(f"  no selection to check: {line}")

    found = {f"{tier} {lang} {role} {entry_point}"
             for tier, lang, _, role, entry_point, _ in missing}
    known = set()
    if os.path.exists(args.baseline):
        with open(args.baseline, encoding="utf-8") as handle:
            known = {line.split("#")[0].strip() for line in handle}
        known.discard("")

    print(f"{len(found)} selection(s) name a plugin the build never installs; "
          f"{len(known)} are recorded in the baseline")

    new = sorted(found - known)
    fixed = sorted(known - found)

    if new:
        print(f"\nNEW, and not in the baseline ({len(new)}):")
        for line in new:
            print(f"  {line}")
        print("\nThe image would boot with this written in mycroft.conf and "
              "the plugin absent. Install it in the tier's build, or change "
              "what autoconfigure selects.")
    if fixed:
        print(f"\nFIXED, and still in the baseline ({len(fixed)}):")
        for line in fixed:
            print(f"  {line}")
        print(f"\nRemove these from {os.path.relpath(args.baseline, REPO)}. A "
              "baseline that keeps entries nobody has to fix stops being read.")
    if new or fixed:
        return 1

    if known:
        print("\nthe findings are exactly the baseline; nothing new is broken")
    else:
        print("\nevery selected plugin is installed by the build that ships it")
    return 0


if __name__ == "__main__":
    sys.exit(main())
