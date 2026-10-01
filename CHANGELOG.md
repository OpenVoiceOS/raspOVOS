# Changelog

Notable changes to the raspOVOS images and build system. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); entries land under
**Unreleased** and move into a dated section when a release is published
(releases are tagged `raspOVOS-<variant>-<YYYY-MM-DD>`).

## [Unreleased]

### Added
- `LICENSE` (Apache-2.0), `CHANGELOG.md`, `CONTRIBUTING.md`, roadmap-task
  issue template
- ShellCheck CI gate over all shell scripts (`make lint`)
- Three-tier image validation, identical locally and in CI (`make
  test-static` / `test-chroot` / `test-boot`): static assertions, chroot
  functional checks (venv imports, pip check, unit Exec-target sweep), and
  a nightly qemu boot smoke test with journal-error checking
- `make dev-shell` — interactive shell inside an image for debugging
- `/opt/ovos/build-manifest.json` in every image: variant, language, base
  OS, python ABI, constraints, base image URL, git SHA, workflow run, and
  the fully resolved package list
- Documentation site (`docs/`, mkdocs-material) covering users and
  developers, deployed to GitHub Pages and strict-built on every PR
- Downstream-contract guard: PRs touching contract paths must state
  BREAKING or `contract: unchanged` (see `docs/reference/downstream.md`)

### Changed
- Build workflows gate release uploads on the Tier 1+2 smoke tests
- Full and language builds resolve the newest DEV base release dynamically
  (`scripts/ci/resolve_base_image.sh`) instead of hardcoded URLs frozen at
  2025-06-18; a `workflow_dispatch` input overrides for reproducing old
  builds. The auto-PR jobs that rewrote those URLs are removed.
- Prebuilt wheels (ggwave, llama-cpp-python) are selected by python ABI
  from `wheels.txt` and the build hard-fails on an unknown ABI instead of
  shipping a broken package after a python bump

### Fixed
- `ovos-audio-diagnostics` executed the sound-server name as a command
  instead of comparing it, so its alsa/pulseaudio fallbacks never ran
- `local_build.sh` / `local_build_all.sh` pointed at nonexistent build
  scripts and could not run; both are functional again with `--help`,
  dependency checks, and variant/language selection
