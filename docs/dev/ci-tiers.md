# CI tiers

Three validation tiers, cheapest first. All live in `scripts/ci/` and run
identically in CI (as required workflow steps) and locally (via `make`).

## Tier 1 — static image assertions (`assert_image.sh`)

Loop-mounts the image read-only and runs **table-driven** assertion lists
from `scripts/ci/assertions.d/` (`common.txt` always; extra tables per
variant). One assertion per line:

```
file_exists <path>              file_absent <path>
symlink_valid <path>            unit_enabled <unit> <wants-dir>
user_exists <name> <uid>        linger_enabled <user>
json_valid <path>               grep_file <path> <regex>
```

**To add a check, add a line to a table.** Do not edit the script. Every
provisioning change should land with a matching assertion.

## Tier 2 — chroot functional checks (`chroot_checks.sh`)

Executes the image's own arm64 binaries via qemu-user binfmt (no pid1, no
audio, no network):

1. venv imports from `scripts/ci/imports.d/<variant>.txt`
2. `pip check` (dependency-graph consistency)
3. every shipped `.service` file's `Exec*` binaries exist **in the image**
   — this is the check that catches a helper script renamed upstream but
   not in the unit file.

## Tier 3 — qemu boot smoke (`qemu_boot_test.sh`)

Boots the image on the qemu `virt` machine with the image's own kernel,
drives the serial console (expect): waits for login, asserts all `ovos-*`
user units reach `active` within 120 s, and fails on any
`journalctl -p err` line not matched by `journal-allowlist.txt`. Every
allowlist entry must carry a comment saying why it is benign. The serial
log is always kept as an artifact.

Runs nightly against the newest DEV base and on demand
(`workflow_dispatch` with an image URL). **Not covered:** Pi firmware,
device-tree, HATs, real audio — see the
[release checklist](release-checklist.md).

## Where they run in CI

| Workflow | Tiers |
|----------|-------|
| every image build (base + languages) | 1 + 2, gating release upload |
| `smoke_nightly.yml` | 3 |
| `shellcheck.yml` | lint on every PR |
