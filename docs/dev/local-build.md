# Build images locally

Everything CI does, you can do on a Linux laptop. Same scripts, same
results.

## Host requirements

Any x86_64 Linux with root. Install:

```bash
# Debian/Ubuntu
sudo apt install qemu-user-static binfmt-support systemd-container \
                 parted xz-utils wget file expect qemu-system-arm
# Arch
sudo pacman -S qemu-user-static qemu-user-static-binfmt systemd \
               parted xz wget file expect qemu-system-aarch64
```

`qemu-user-static` + binfmt is the key piece: it lets the arm64 binaries
inside the image run on your x86 machine during provisioning. Verify:

```bash
ls /proc/sys/fs/binfmt_misc/ | grep aarch64   # should list qemu-aarch64
```

You also need ~10 GB free disk per image being built.

## Build one image

```bash
./local_build.sh --help                     # all options
sudo ./local_build.sh                       # lite base from the pinned Pi OS
sudo ./local_build.sh \
    --script-path lang_builds/hybrid/build_raspOVOS_pt.sh \
    --base-image ./raspOVOS-DEV-bookworm-arm64-lite-base.img \
    --image-output-path raspOVOS-pt-hybrid.img
```

`--base-image` accepts a URL or a local file. `--shrink` runs PiShrink,
`--compress-with-xz` produces the release-style `.img.xz`.

## Build a whole variant

```bash
sudo ./local_build_all.sh --variant hybrid              # base + all langs
sudo ./local_build_all.sh --variant lite --langs "pt en"
sudo ./local_build_all.sh --variant lite --langs pt \
    --skip-base --base-image ./my-base.img              # reuse a base
```

Or via make: `make build VARIANT=lite`.

## Poke around inside an image

```bash
sudo make dev-shell IMG=raspOVOS-pt-hybrid.img
```

drops you into a shell **inside** the image (nspawn + qemu). Changes
persist in the image file — handy for quick experiments, but rebuild
properly before sharing anything.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `Exec format error` inside nspawn | binfmt not registered — reinstall qemu-user-static / `systemctl restart systemd-binfmt` |
| `losetup: cannot find an unused loop device` | `sudo modprobe loop`; detach leftovers with `losetup -D` |
| build dies mid-way, loop devices leak | `sudo umount -R /tmp/rpi-image-modifier-raspOVOS/mnt; sudo losetup -D` |
| very slow package installs | normal — arm64 emulation costs 5-10× |

## Next steps

- [Test images locally & in CI](local-testing.md) — validate what you built.
