# Downstream contract

Other images build **on top of** published raspOVOS bases (for example
HiveMind hub images). The interfaces below are a contract: changing any of
them is a **breaking change** that must be flagged `BREAKING` in the PR
and called out in release notes.

## Stable interfaces

| Interface | Value |
|-----------|-------|
| User account | `ovos`, uid `1000`, gid `1000`, lingering enabled |
| Home | `/home/ovos` |
| OVOS venv | `/home/ovos/.venvs/ovos` (system-site-packages) |
| Release channel file | `/opt/ovos/tag` |
| Build manifest | `/opt/ovos/build-manifest.json` |
| User unit names | `ovos.service`, `ovos-messagebus.service`, `ovos-skills.service`, `ovos-audio.service`, `ovos-listener.service`, `ovos-phal.service`, `ovos-gui.service` |
| System unit names | `ovos-admin-phal.service`, `i2csound.service`, `autoconfigure_soundcard.service` |
| Config layering | `/etc/mycroft/mycroft.conf` (image) ← `~/.config/mycroft/mycroft.conf` (user) |
| Overlay layering order | `base` → `base_gui` → `base_ovos` → `base_ovos_offline` → per-language |
| Release tagging | `raspOVOS[-DEV]-bookworm-arm64-<variant>[-<lang>]-<YYYY-MM-DD>` |

## For downstream builders

Base your build on a **dated release URL** (reproducible), not "latest".
Read `/opt/ovos/build-manifest.json` at build time and record it in your
own artifact. If your provisioning adds services for the `ovos` user,
drop them in `/home/ovos/.config/systemd/user/` and enable via
`default.target.wants` symlinks like the base image does.
