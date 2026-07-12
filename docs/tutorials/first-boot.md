# First boot & talking to OVOS

You flashed a card and powered the Pi on. Here is what happens next and
how to have your first conversation.

## What to expect

On first boot the image expands its filesystem and starts the OVOS
services under the `ovos` user. Give it a few minutes on the first run;
later boots are faster. If a display is connected you will see a splash
screen, then a console login.

You do not need to log in for the assistant to work — everything starts
automatically.

## Say something

Get within a metre of the microphone and say:

> **"Hey Mycroft… what time is it?"**

Then try:

> "Hey Mycroft, set a timer for five minutes."
> "Hey Mycroft, tell me a joke."
> "Hey Mycroft, what's the weather like?" *(needs internet)*

If nothing happens, run through [Troubleshoot audio](../how-to/troubleshoot-audio.md)
— nine times out of ten it is the microphone or the default audio output.

## Log in (optional, useful)

Locally or over SSH (`ssh ovos@raspOVOS.local`, password `ovos`):

```bash
ovos-help        # list of raspOVOS commands
ovos-commands    # what you can say
ls-skills        # installed skills
systemctl --user status ovos.service   # service health
```

!!! danger "Change the default password"
    The default `ovos`/`ovos` credentials are public knowledge. If the
    device stays on your network, run `passwd` now.

## Next steps

- [Change the voice or STT](../how-to/change-voice-stt.md) — pick a voice
  you like or move speech recognition on-device.
- [Update your device](../how-to/update.md) — keep the stack fresh.
