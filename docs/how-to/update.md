# Update your device

There are two different kinds of update — know which one you are doing.

## 1. Updating the OVOS stack (routine)

`ovos-update` upgrades the Python packages in the OVOS venv against the
release channel recorded in `/opt/ovos/tag` (images ship on `alpha`):

```bash
ovos-update
```

This is safe, in-place, and keeps your configuration. Run it whenever you
want fixes and new features. System packages update the normal Debian way
(`sudo apt update && sudo apt full-upgrade`).

## 2. Moving to a new image (major)

New base images (new Raspberry Pi OS, new defaults) require reflashing.
Before you reflash, save your identity and configuration:

```bash
tar czf /boot/firmware/ovos-backup.tar.gz \
    -C /home/ovos .config/mycroft .local/share/mycroft
```

The boot partition is FAT — you can also read that file from any laptop
by inserting the SD card. After flashing the new image, restore:

```bash
tar xzf /boot/firmware/ovos-backup.tar.gz -C /home/ovos
systemctl --user restart ovos.service
```

## Which version am I on?

```bash
cat /opt/ovos/tag                      # release channel
python3 -m json.tool /opt/ovos/build-manifest.json | head -20   # exact build
```

The [build manifest](../reference/build-manifest.md) records the exact
package pins your image shipped with — include it in bug reports.

## Next steps

- [Get help (support bundle)](support-bundle.md) if an update broke something.
