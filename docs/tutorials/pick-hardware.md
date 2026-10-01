# Pick a microphone & speaker

raspOVOS works with almost any audio hardware the Pi can see, and
auto-configures the common cases at boot.

## The easy path: USB

A cheap **USB conference microphone/speakerphone** (or separate USB mic +
3.5 mm/HDMI speaker) is the most reliable option. Plug it in; the image's
soundcard autoconfiguration prefers USB audio when present and re-runs on
hot-plug.

## HATs (I²C audio boards)

At boot, `ovos-i2csound` probes the I²C bus and configures detected boards
automatically, including ReSpeaker 2-mic/4-mic/6-mic arrays, WM8960-based
boards, SJ-201 (Mark II) and AIY VoiceKit. If your HAT is detected you
will find its name in `/etc/OpenVoiceOS/i2c_platform`.

```bash
cat /etc/OpenVoiceOS/i2c_platform   # which board was detected
ovos-audio-diagnostics              # what the sound stack sees
```

## Priorities, when several outputs exist

The autoconfiguration picks the default output in this order: **USB →
non-onboard cards (HATs/DACs) → headphone jack → HDMI**. You can always
override it — see [Troubleshoot audio](../how-to/troubleshoot-audio.md).

## Next steps

- [First boot & talking to OVOS](first-boot.md)
- [Troubleshoot audio](../how-to/troubleshoot-audio.md)
