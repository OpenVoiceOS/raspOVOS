# CLI tools

Commands the image ships in `/usr/local/bin` (run as the `ovos` user).

| Command | What it does |
|---------|--------------|
| `ovos-help` | overview of available commands |
| `ovos-commands` | example voice commands |
| `ovos-update` | update the OVOS stack from the channel in `/opt/ovos/tag` |
| `ovos-reset-brain` | reset OVOS state/config to image defaults |
| `ovos-support` | collect logs/config into a support bundle (see [caveats](../how-to/support-bundle.md)) |
| `ovos-audio-diagnostics` | print sound server, sinks and default output |
| `ovos-audio-setup` | interactive audio configuration menu |
| `ls-skills` | list installed skills |
| `ls-stt` / `ls-tts` / `ls-ww` / `ls-tx` | list installed STT / TTS / wake-word / translation plugins |
| `ovos-logo` | print the logo (yes, really) |

Helpers in `/usr/libexec` (used by systemd, not typed by hand):
`ovos-i2csound` (HAT detection), `soundcard-autoconfigure` (default output
selection), `usb-autovolume`, the `ovos-systemd-*` service launchers and
the bus signal emitters (`ovos-reboot-signal`, `ovos-shutdown-signal`, …).

These tools are developed in
[OpenVoiceOS/ovos-tools](https://github.com/OpenVoiceOS/ovos-tools) and
[OpenVoiceOS/raspovos-audio-setup](https://github.com/OpenVoiceOS/raspovos-audio-setup)
and shipped into the image at build time.
