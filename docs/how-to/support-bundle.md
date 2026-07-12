# Get help (support bundle)

`ovos-support` collects logs and configuration into a bundle you can share
when asking for help:

```bash
ovos-support
```

!!! warning "Read before you upload"
    Today the bundle is uploaded to a **public** paste service and is not
    yet redacted — it can contain your Wi-Fi network names, configuration
    and log contents. Review what you share. Hardening (redaction of
    secrets + explicit consent prompt + local-only mode) is tracked in
    [#131](https://github.com/OpenVoiceOS/raspOVOS/issues/131).

## What helps a bug report

- The **build manifest**: `/opt/ovos/build-manifest.json` — identifies your
  exact image and package pins.
- The failing service's log:
  `journalctl --user -u ovos-skills -e` (or `ovos-listener`, `ovos-audio`…).
- What you said, what you expected, what happened.

## Where to ask

- [OVOS Matrix/Discord community](https://openvoiceos.org/community/)
- [raspOVOS issues](https://github.com/OpenVoiceOS/raspOVOS/issues) for
  image bugs (build failures, services not starting, hardware detection).
