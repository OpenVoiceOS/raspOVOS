# raspOVOS

raspOVOS turns a Raspberry Pi into a private, open-source voice assistant. You flash an SD card, boot the Pi, and talk to it. No cloud account or subscription is needed, and no data leaves your home unless you choose it.

It is the flagship [OpenVoiceOS](https://openvoiceos.org) experience: ready-made images with the whole OVOS stack. Wake word, speech-to-text, intent handling, skills, and text-to-speech come preinstalled, preconfigured, and tuned for Raspberry Pi hardware.

## Choose your image

Three variants trade privacy/latency against hardware requirements, each
available in ~12 languages:

| Variant | STT | TTS | Needs | Best for |
|---------|-----|-----|-------|----------|
| **lite** | public servers | public servers | Pi 3 might work, Pi 4 better | trying it out on older hardware |
| **hybrid** | public servers | **on device** | Pi 4 | balanced daily driver |
| **offline** | **on device** | **on device** | Pi 4/5 with 4 GB+ RAM (8 GB best) | full privacy, no internet dependency |

!!! note "About the public servers"
    They are hosted by volunteers on a best-effort basis. Latency and
    uptime vary. If you have a bigger machine on your network, you can
    [self-host STT/TTS](https://openvoiceos.github.io/ovos-technical-manual/200-stt_server/)
    and point any variant at it.

## Get started in three steps

1. **Download** an image from the
   [releases page](https://github.com/OpenVoiceOS/raspOVOS/releases).
   Pick your variant and language.
2. **Flash** it to an SD card. Follow
   [Flash your first image](tutorials/flash-your-first-image.md).
3. **Boot and talk**. See [First boot & talking to OVOS](tutorials/first-boot.md).

Default credentials: user `ovos`, password `ovos`, hostname `raspOVOS`.

!!! warning
    Do **not** change the default username when flashing. The images
    expect the `ovos` user to exist.

## Where to next

- New to all of this? Start with the [tutorials](tutorials/flash-your-first-image.md).
- Something specific to do? See the [how-to guides](how-to/change-voice-stt.md).
- Want to know what is inside? Read
  [What we change on Raspberry Pi OS](explanation/anatomy.md).
- Building or modifying images? Head to [Developing](dev/local-build.md).
