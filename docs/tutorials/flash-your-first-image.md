# Flash your first image

This tutorial takes you from nothing to a bootable raspOVOS SD card. You
need: a Raspberry Pi (4 or 5 recommended), a microSD card (16 GB minimum,
32 GB recommended), a card reader, and a computer.

## 1. Pick and download an image

Go to the [releases page](https://github.com/OpenVoiceOS/raspOVOS/releases)
and pick the newest release for your variant and language — see
[Image variants & languages](../reference/variants.md) if you are unsure.
For a first try on a Pi 4, `hybrid` in your language is a good default.

You will download a file like
`raspOVOS-pt-bookworm-arm64-hybrid.img.xz`. No need to extract it —
flashing tools understand `.xz`.

## 2. Flash the SD card

Use the official [Raspberry Pi Imager](https://www.raspberrypi.com/software/):

1. Click **Choose OS → Use custom** and select the `.img.xz` you downloaded.
2. Click **Choose storage** and select your SD card.
3. Click **Next**.

!!! warning "Skip OS customization"
    When the Imager offers to apply OS customization (username, Wi-Fi…),
    choose **No**. The image expects its default `ovos` user; changing the
    username breaks the services.

Any other flasher (balenaEtcher, `dd`) works too.

## 3. Wi-Fi (if you have no Ethernet)

If the Pi will use Ethernet, skip this. For Wi-Fi, the simplest path today
is: connect a keyboard and screen for first boot, log in (`ovos` / `ovos`)
and run:

```bash
sudo raspi-config
# System Options -> Wireless LAN
```

## 4. Boot

Insert the card, connect audio hardware (see
[Pick a microphone & speaker](pick-hardware.md)), and power on. The first
boot takes a few minutes while the filesystem expands.

## Next steps

- [First boot & talking to OVOS](first-boot.md) — what to expect and your
  first voice commands.
- [Pick a microphone & speaker](pick-hardware.md) — if you have not sorted
  audio hardware yet.
