# Release checklist

CI proves the software stack (Tiers 1–3); this checklist covers what only
real hardware can prove. A human runs it before promoting a build to a
stable (non-DEV) release. Check off with the image name and date.

## Hardware matrix

Flash the release candidate and verify on at least one Pi 4 **and** one
Pi 5:

- [ ] First boot completes; filesystem expanded; services active within
      2 minutes of boot (`systemctl --user status ovos.service`)
- [ ] Wake word triggers from ~1 m; full round-trip (question → spoken
      answer) works
- [ ] Audio out via headphone jack **and** HDMI **and** a USB device
- [ ] At least one I²C HAT detected end-to-end
      (`/etc/OpenVoiceOS/i2c_platform` populated, mic + speaker work)
- [ ] USB audio hot-plug switches the default output
- [ ] Wi-Fi joins a network (`raspi-config`); `raspOVOS.local` resolves
- [ ] Reboot: everything comes back without intervention
- [ ] `ovos-update` runs clean on the flashed image
- [ ] Flash via Raspberry Pi Imager (not just dd) boots

## Release hygiene

- [ ] Tier 3 green on the exact artifact being promoted
- [ ] `build-manifest.json` attached to the release and sane
      (constraints URL, git SHA, package count)
- [ ] sha256sums published alongside the images
- [ ] CHANGELOG Unreleased section moved into the release
- [ ] Known issues listed in the release notes

## Regressions found

File each as an issue with the `release-blocker` label, linking the serial
log or journal snippet. A blocker means the candidate is not promoted.
