# systemd units

OVOS runs as **user services** of the `ovos` user (lingering enabled, so
they start at boot without login). Hardware/root concerns run as system
services.

## User units (`systemctl --user …`)

| Unit | Role |
|------|------|
| `ovos.service` | umbrella target for the stack |
| `ovos-messagebus.service` | the message bus every component connects to |
| `ovos-skills.service` | skill loading and intent handling |
| `ovos-audio.service` | TTS playback and audio output |
| `ovos-listener.service` | microphone, wake word, STT |
| `ovos-phal.service` | platform/hardware abstraction (user side) |
| `ovos-gui.service` | GUI message bus (display optional) |
| `ovos-ggwave.service` | data-over-sound pairing |
| `ovos-yaml-editor.service`, `ovos-skill-settings-ui.service` | web config UIs |
| `gmrender.service` | DLNA renderer |
| `ovos-librespot.service`, `ovos-spotifyd.service` | Spotify (disabled by default) |

## System units (`sudo systemctl …`)

| Unit | Role |
|------|------|
| `ovos-admin-phal.service` | root-level PHAL plugins (system python) |
| `i2csound.service` | I²C audio HAT detection at boot |
| `autoconfigure_soundcard.service` | default audio output selection |
| `splashscreen.service` | boot splash |
| `ovos-reboot-signal.service`, `ovos-shutdown-signal.service` | emit bus messages on reboot/shutdown |

## Handy commands

```bash
systemctl --user status ovos.service        # stack health at a glance
journalctl --user -u ovos-skills -e         # a service's log
systemctl --user restart ovos-listener      # after config changes
```
