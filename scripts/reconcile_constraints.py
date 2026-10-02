#!/usr/bin/env python3
"""Reconcile the packages an image inherited with the constraints file.

A constraint binds a package the resolver is asked about. A language build asks
about the packages it installs, so a package that came from the base image and
is named by nothing is never reconsidered: its version stays where the base
release froze it, however far the constraints file has moved since.

That is how T-5125 happened. The base release of 2026-07-12 carried
ovos-plugin-common-play 1.3.4a1, which caps padacioso below 2.0.0. The language
stage lifted padacioso to 2.4.1a1 without naming ovos-plugin-common-play, so
`pip check` failed on every hybrid image while every install line of the build
was correct on its own.

This script names them. It compares every installed distribution against the
constraints file, upgrades the ones that violate it, proves the violation is
gone, and then runs `pip check`. It reports the next package to drift this way,
not this one only.

Usage:  reconcile_constraints.py <constraints-url-or-path> [--verify-only]

Run it with the image's venv python: that interpreter's environment is the one
read and the one repaired. `--verify-only` measures and repairs nothing, which
is how the script re-reads the environment after its own install.

Exit codes: 0 reconciled and `pip check` clean; 1 a violation survived the
upgrade, or `pip check` found broken requirements; 2 the constraints file could
not be read.
"""
import os
import subprocess
import sys
import urllib.request
from importlib.metadata import distributions

from packaging.requirements import InvalidRequirement, Requirement
from packaging.utils import canonicalize_name


def read_constraints(source: str) -> str:
    """The text of the constraints file, from a URL or a path."""
    if source.startswith(("http://", "https://")):
        with urllib.request.urlopen(source, timeout=60) as response:
            return response.read().decode("utf-8")
    with open(source, "r", encoding="utf-8") as handle:
        return handle.read()


def parse_constraints(text: str):
    """The requirements the file states, one per line, unparsable lines skipped.

    A constraints file holds pip option lines and comments as well. Anything
    that is not a requirement is not a constraint on a package, so it is
    skipped and counted, never guessed at.
    """
    requirements, skipped = [], 0
    for raw in text.splitlines():
        line = raw.split("#", 1)[0].strip()
        if not line or line.startswith("-"):
            continue
        try:
            requirements.append(Requirement(line))
        except InvalidRequirement:
            skipped += 1
    return requirements, skipped


def installed_versions():
    """Canonical distribution name -> (version, location), for this interpreter.

    The location matters. The image's venv is created with
    --system-site-packages and three packages are installed into the system
    python before it (build_raspOVOS_base_lite.sh), so a distribution this
    interpreter imports may live outside the venv, where installing into the
    venv does not replace it.
    """
    found = {}
    for dist in distributions():
        name = dist.metadata["Name"]
        # first on sys.path wins, which is the copy that imports: a venv copy
        # shadows a system-site copy of the same distribution
        if name and canonicalize_name(name) not in found:
            location = ""
            try:
                location = str(dist.locate_file("")).rstrip("/")
            except Exception:
                pass
            found[canonicalize_name(name)] = (dist.version, location)
    return found


def violations(requirements, installed):
    """The installed packages the constraints file contradicts.

    Only installed packages are reported: a constraint on a package the image
    does not carry is not a defect. Prereleases are allowed, because the alpha
    channel is what these images install.
    """
    found = []
    for req in requirements:
        if req.marker is not None and not req.marker.evaluate():
            continue
        name = canonicalize_name(req.name)
        entry = installed.get(name)
        if entry is None:
            continue
        version, location = entry
        if not req.specifier.contains(version, prereleases=True):
            found.append((name, version, str(req.specifier), location))
    return sorted(found)


def report(found) -> None:
    for name, version, specifier, location in found:
        where = "" if in_venv(location) else f"  <- outside the venv: {location}"
        print(f"  {name} {version} violates {specifier}{where}")


def in_venv(location: str) -> bool:
    """True when this copy lives in the environment being repaired."""
    return bool(location) and location.startswith(sys.prefix)


def main(argv) -> int:
    if not argv or argv[0] in ("-h", "--help"):
        print(__doc__)
        return 2
    # the build log must read in the order things happened, and this script
    # interleaves its own prints with a subprocess's output
    sys.stdout.reconfigure(line_buffering=True)
    constraints = argv[0]
    verify_only = "--verify-only" in argv[1:]

    try:
        text = read_constraints(constraints)
    except Exception as error:  # a URL that does not answer, a path that is gone
        print(f"ERROR: cannot read constraints {constraints}: {error}")
        return 2

    requirements, skipped = parse_constraints(text)
    installed = installed_versions()
    print(f"constraints: {len(requirements)} requirements "
          f"({skipped} lines skipped), {len(installed)} packages installed")

    found = violations(requirements, installed)
    if not found:
        print("no inherited package violates the constraints file")
        return 0 if verify_only else pip_check()

    print(f"{len(found)} inherited package(s) violate the constraints file:")
    report(found)
    if verify_only:
        return 1

    names = [name for name, _, _, _ in found]
    # Each requirement carries the specifier it violates, never the bare name.
    # A bare name lets uv answer with a copy it already sees: run 36204852657
    # left seven packages untouched that way, the ones the base image installed
    # into the system python and the venv reads through --system-site-packages.
    # An explicit floor cannot be satisfied by the version that violates it.
    pinned = [f"{name}{specifier}" for name, _, specifier, _ in found]
    # --reinstall-package as well, because uv can treat an installed prerelease
    # as satisfying the requirement and move nothing: an upgrade that silently
    # does nothing would leave this script reporting success on an unchanged
    # environment.
    command = [
        "uv", "pip", "install", "--no-progress", "--upgrade",
        "--python", sys.executable,
        "-c", constraints,
    ]
    for name in names:
        command += ["--reinstall-package", name]
    command += pinned
    print("+ " + " ".join(command))
    environment = dict(os.environ, UV_PRERELEASE="allow")
    if subprocess.call(command, env=environment) != 0:
        print("ERROR: the reconcile install failed")
        return 1

    # A fresh interpreter, because importlib.metadata read the environment
    # before the install changed it.
    verify = subprocess.call(
        [sys.executable, os.path.abspath(__file__), constraints, "--verify-only"])
    if verify != 0:
        print("ERROR: a violation survived the upgrade")
        print("Two causes are possible, and they need opposite fixes. The "
              "usual one is a requirement without a floor: the resolver was "
              "free to keep the old version, and naming the floor in the "
              "requirement fixes it. This happened on run 36204852657, where "
              "seven packages read through --system-site-packages survived, "
              "and a venv install then shadowed every one of them. The other "
              "is a copy a venv install cannot shadow, such as one on "
              "PYTHONPATH, which precedes site-packages. A copy in the system "
              "python is NOT that case: do not install into the system "
              "python to clear this.")
        return 1
    return pip_check()


def pip_check() -> int:
    """`pip check` on this interpreter: the check Tier 2 runs, run at build time.

    Tier 2 finds a broken requirement after an image is built and compressed.
    Running the same check here names the build step that introduced it.
    """
    print("+ pip check")
    # A check that cannot run must not report the failure it is looking for.
    # Without pip, `-m pip check` exits non-zero with "No module named pip",
    # which reads in a build log exactly like a broken requirement.
    if subprocess.call([sys.executable, "-m", "pip", "--version"],
                       stdout=subprocess.DEVNULL,
                       stderr=subprocess.DEVNULL) != 0:
        print("ERROR: pip is not installed in this interpreter, so pip check "
              "could not run. This is not a broken requirement: the check did "
              "not happen.")
        return 1
    if subprocess.call([sys.executable, "-m", "pip", "check"]) != 0:
        print("ERROR: pip check reported broken requirements")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
