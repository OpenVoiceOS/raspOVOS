# Troubleshoot audio

Most "it doesn't answer" reports are audio plumbing. Work down this list.

## 1. See what the system sees

```bash
ovos-audio-diagnostics
```

This prints the detected sound server (PipeWire on stock images), the
available outputs, and the current default. No output devices listed →
hardware/cabling problem. Wrong default → step 3.

## 2. Is the mic heard?

```bash
wpctl status                 # find your source (microphone) id
arecord -d 3 test.wav && aplay test.wav   # record 3s and play it back
```

If the recording is silent, check `wpctl` volume/mute on the source:
`wpctl set-volume <id> 1.0` / `wpctl set-mute <id> 0`.

## 3. Wrong output selected

The image auto-picks USB → HAT/DAC → headphone jack → HDMI at boot and on
USB hot-plug. To re-run the selection or pick manually:

```bash
sudo systemctl restart autoconfigure_soundcard.service   # re-run auto pick
ovos-audio-setup                                          # interactive menu
```

## 4. HAT not detected

```bash
cat /etc/OpenVoiceOS/i2c_platform     # empty? the board wasn't recognized
sudo i2cdetect -y 1                   # is the board on the bus at all?
sudo systemctl restart i2csound.service
```

## 5. Services healthy?

```bash
systemctl --user status ovos-listener ovos-audio
journalctl --user -u ovos-listener -e   # listener log (wake word, STT)
```

## Still stuck

Generate a [support bundle](support-bundle.md) and ask in the
[OVOS community channels](https://openvoiceos.org/community/).
