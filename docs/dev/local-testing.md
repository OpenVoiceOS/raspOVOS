# Test images locally & in CI

CI and your laptop run the **byte-identical commands** — every workflow
calls the same `make` targets you do. If it is green locally, it is green
in CI.

```bash
make lint                          # shellcheck over the whole repo
sudo make test-static IMG=out.img.xz          # Tier 1  (~2 min)
sudo make test-chroot IMG=out.img.xz VARIANT=lite   # Tier 2  (~10 min)
sudo make test-boot   IMG=out.img.xz          # Tier 3  (~20-40 min)
```

All three accept `.img` or `.img.xz`. See [CI tiers](ci-tiers.md) for
what each tier checks and how to extend it.

## Which tier when

- Touched an **overlay, unit file or provisioning script** → Tier 1 + 2.
- Touched **first-boot behavior, service ordering, anything systemd-runtime**
  → also Tier 3.
- Touched **docs only** → none (the docs build checks itself).

## Testing without a full build

Tier 1's assertion engine can run against any unpacked rootfs directory —
useful for testing new assertions without a 40-minute build:

```bash
RASPOVOS_CI_ROOTFS=/path/to/rootfs ./scripts/ci/assert_image.sh -
```

## The rule for new test infra

Any new check must be **proven to fail** on an injected defect before it
counts as done (rename a unit, break a config, point at a missing model —
then show the red run). A check that has never failed proves nothing.

## What CI cannot see

Tier 3 boots the `virt` qemu machine, not real Pi hardware: firmware,
device-tree, HATs, actual audio and Wi-Fi are **not** exercised. Those
live in the [release checklist](release-checklist.md), executed by a
human on real hardware before a stable release.
