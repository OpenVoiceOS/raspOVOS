# Contributing to raspOVOS

raspOVOS builds the official OpenVoiceOS Raspberry Pi images. This is an
image-build pipeline, not a Python package: the "code" is provisioning shell
scripts, filesystem overlays, and GitHub Actions workflows.

## Ground rules

- **Branches:** work on a feature branch, open a **draft PR into `dev`**.
  Mark it ready only when CI is green. Never push to `dev` directly.
- **Commits:** use [conventional commits](https://www.conventionalcommits.org/)
  (`feat:`, `fix:`, `ci:`, `docs:`, …). Breaking changes to the image contract
  (user name, venv path, unit names, `/opt/ovos/*`) must use `feat!:` and call
  out **BREAKING** in the PR body — downstream images build on top of raspOVOS.
- **One overlay layer per PR:** never edit two `overlays/` layers
  (`base`, `base_gui`, `base_ovos`, `base_ovos_offline`, per-language) in the
  same PR.
- **Update `CHANGELOG.md`** (Unreleased section) in any PR that changes what
  ships in an image.

## Shell style

Every `*.sh` file and every extensionless shebang script under `overlays/`
must pass ShellCheck at error severity:

```bash
./scripts/ci/run_shellcheck.sh
```

CI runs exactly this script — if it is green locally, it is green in CI.

## Building locally

```bash
./local_build.sh --help        # single image (base or one provisioning script)
./local_build_all.sh --help    # base + all language images for one variant
```

Requirements: `qemu-user-static` (binfmt), `systemd-container`
(systemd-nspawn), `parted`, `xz`, and root via sudo.

## Releases

Images are built by the GitHub Actions workflows and published to GitHub
Releases with date-tagged names (`raspOVOS-<variant>-<YYYY-MM-DD>`). Dev base
images use the `raspOVOS-DEV-` prefix and feed the language image builds.
