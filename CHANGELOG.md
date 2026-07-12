# Changelog

Notable changes to the raspOVOS images and build system. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); entries land under
**Unreleased** and move into a dated section when a release is published
(releases are tagged `raspOVOS-<variant>-<YYYY-MM-DD>`).

## [Unreleased]

### Added
- `LICENSE` (Apache-2.0), `CHANGELOG.md`, `CONTRIBUTING.md`
- ShellCheck CI gate over all shell scripts (`scripts/ci/run_shellcheck.sh`)

### Fixed
- `ovos-audio-diagnostics` executed the sound-server name as a command
  instead of comparing it, so its alsa/pulseaudio fallbacks never ran
- `local_build.sh` / `local_build_all.sh` pointed at nonexistent build
  scripts and could not run; both are functional again with `--help`
