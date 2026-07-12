# What we change on Raspberry Pi OS

An honest inventory of everything the provisioning does to a stock
Raspberry Pi OS Lite. If you would rather apply OVOS to an existing
system yourself, use
[ovos-installer](https://github.com/OpenVoiceOS/ovos-installer) instead.

## Users & login

- The default `pi` user becomes `ovos` (uid 1000), password `ovos`,
  member of `sudo audio pipewire rtkit ovos`; autologin enabled;
  `userconf.txt` written so the first-boot wizard doesn't rename it back.
- **Lingering** is enabled for `ovos` so its user services start at boot
  with no login.
- Hostname set to `raspOVOS`.

## System packages

Audio stack (PipeWire, WirePlumber, ALSA utils, portaudio, mpv, ffmpeg),
build tools for native wheels (build-essential, swig, python3-dev,
libfann-dev, libssl-dev), camera libs (libcamera, kms++), DLNA
(gstreamer, gmediarender), quality-of-life (jq, git, curl, mosh,
i2c-tools, kdeconnect, zram generator).

## Python

- `uv` + `sdnotify` in system python; admin PHAL (`ovos-phal`,
  `ovos-PHAL-plugin-system`) in system python (root-side plugins).
- The whole OVOS stack in `/home/ovos/.venvs/ovos`
  (`--system-site-packages`), pinned by the ovos-releases constraints.
- Skills from `skills.list` (~35), STT/TTS plugins per variant/language,
  pre-downloaded models (wake word, intent classifiers, STT/TTS models on
  offline variants).

## Performance & storage tuning

- **zram swap** via `systemd-zram-generator` (compressed RAM swap instead
  of SD-card swap).
- `/etc/fstab` tuned by `scripts/setup_fstab.sh` (tmpfs for volatile
  paths, reduced SD writes).
- sysctl tweaks for a small-memory appliance; udev rules for audio
  hot-plug reconfiguration.

## Services

See [systemd units](../reference/systemd-units.md) for the full unit map
— OVOS itself under the `ovos` user, hardware detection
(`ovos-i2csound`), audio autoconfiguration, splash screen, and bus
signals for reboot/shutdown as system units.

## What we do NOT change

No telemetry is added anywhere. SSH stays as Raspberry Pi OS ships it.
Nothing phones home: the public STT/TTS servers are only contacted by the
`lite`/`hybrid` variants during actual use, and everything can be pointed
at your own servers — see
[Change the voice or STT](../how-to/change-voice-stt.md).
