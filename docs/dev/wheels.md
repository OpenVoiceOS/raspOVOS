# Prebuilt wheels

Some packages have no aarch64 binaries on PyPI and take hours to compile
under emulation, so the build installs prebuilt wheels listed in
`wheels.txt`:

```
# package  abi    url
ggwave     cp311  https://whl.smartgic.io/ggwave-0.4.2-cp311-cp311-linux_aarch64.whl
```

`scripts/install_wheel.sh <package>` selects the row matching the image
python's ABI tag and **hard-fails the build** with instructions when no
row matches. That is deliberate: a Raspberry Pi OS python bump must fail
loudly at build time, never ship an image with a silently broken package.

## When the base OS python changes

1. Build the wheel for the new ABI on an arm64 machine (or under qemu):
   `uv pip wheel <package> --no-deps`.
2. Publish it (prebuilt binaries live in
   [ovos-binary-shop](https://github.com/OpenVoiceOS/ovos-binary-shop) or
   an equivalent stable URL).
3. Add a row to `wheels.txt` with the new ABI tag. Keep the old row until
   no supported base image uses the old python.
4. Update the Tier 2 import list if the package set changed.
