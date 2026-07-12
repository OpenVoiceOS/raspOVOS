# Change the voice or STT

OVOS configuration lives in `~/.config/mycroft/mycroft.conf` (user
overrides) layered over `/etc/mycroft/mycroft.conf` (image defaults).
Edit as the `ovos` user; services pick up changes on restart.

## Change the TTS voice

```bash
nano ~/.config/mycroft/mycroft.conf
```

```json
{
  "tts": {
    "module": "ovos-tts-plugin-piper",
    "ovos-tts-plugin-piper": {
      "voice": "alan-low"
    }
  }
}
```

Restart audio: `systemctl --user restart ovos-audio`. List installed TTS
plugins with `ls-tts`.

## Change STT

```json
{
  "stt": {
    "module": "ovos-stt-plugin-fasterwhisper",
    "ovos-stt-plugin-fasterwhisper": {
      "model": "small"
    }
  }
}
```

Restart the listener: `systemctl --user restart ovos-listener`. List
installed STT plugins with `ls-stt`. Bigger models are more accurate and
slower — on a Pi 4 stay at `small` or below.

## Use your own STT/TTS server

Any variant can point at a self-hosted server instead of the public ones:

```json
{
  "stt": {"module": "ovos-stt-plugin-server",
          "ovos-stt-plugin-server": {"url": "http://myserver:8080/stt"}},
  "tts": {"module": "ovos-tts-plugin-server",
          "ovos-tts-plugin-server": {"host": "http://myserver:9666"}}
}
```

## Validate your config

A stray comma breaks JSON. Check before restarting:

```bash
~/.venvs/ovos/bin/python -m json.tool ~/.config/mycroft/mycroft.conf
```

## Next steps

- [Troubleshoot audio](troubleshoot-audio.md) if the voice changed but
  nothing plays.
- [Image variants & languages](../reference/variants.md) for the plugin
  defaults per language.
