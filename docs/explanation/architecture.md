# Architecture of the build

raspOVOS is not a Linux distribution — it is a **customization pipeline**
that takes stock Raspberry Pi OS Lite (arm64, Bookworm) and provisions
OVOS on top, entirely inside the image file, without hardware.

## The pipeline

```
Raspberry Pi OS Lite (raspberrypi.com)
        │  build_raspOVOS_base_lite.sh          → raspOVOS-DEV-…-lite
        │  build_raspOVOS_base_full.sh (on top) → raspOVOS-DEV-…-offline
        │  lang_builds/<variant>/build_raspOVOS_<lang>.sh
        ▼
raspOVOS-<lang>-…-<variant>   (what users flash)
```

Each step: the image is loop-mounted and grown, a provisioning script is
copied inside, and it runs in an emulated arm64 container
(`systemd-nspawn` + `qemu-user-static`). In CI this is driven by
[TigreGotico/rpi-image-modifier](https://github.com/TigreGotico/rpi-image-modifier);
locally, `local_build.sh` does the identical dance. Finally the image is
shrunk (PiShrink) and xz-compressed.

## Overlays

Static files come from `overlays/`, copied in a strict order — each layer
may build on the previous, and a PR must only touch one layer:

| Layer | Contents |
|-------|----------|
| `base` | OS-level: audio autoconfig units, udev rules, CLI helpers |
| `base_gui` | ovos-shell service + GPU config (not wired into builds yet) |
| `base_ovos` | mycroft.conf, all OVOS systemd units, bus emitters, launchers |
| `base_ovos_offline` | offline-variant additions (models config, personas) |
| `<lang>` | per-language config |

## Dynamic parts

- **Python stack**: installed with `uv pip install --pre` against the
  [ovos-releases](https://github.com/OpenVoiceOS/ovos-releases)
  `constraints-alpha.txt` — the single source of version pinning. The
  resolved result is frozen into the
  [build manifest](../reference/build-manifest.md).
- **Prebuilt wheels**: packages with no aarch64 binaries on PyPI (ggwave,
  llama-cpp-python) come from `wheels.txt`, selected by python ABI — see
  [Prebuilt wheels](../dev/wheels.md).
- **Base image resolution**: the full/language workflows resolve the newest
  published DEV base release at run time (`scripts/ci/resolve_base_image.sh`),
  overridable per run to reproduce old builds.

## Quality gates

Every CI build must pass Tier 1 (static assertions) and Tier 2 (chroot
functional checks) before an image is released; a nightly job boots the
newest base in qemu (Tier 3). The same checks run locally via `make` —
see [CI tiers](../dev/ci-tiers.md).

## Next steps

- [Build images locally](../dev/local-build.md)
- [What we change on Raspberry Pi OS](anatomy.md)
