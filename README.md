# RaspOVOS

Using [dtcooper/rpi-image-modifier](https://github.com/dtcooper/rpi-image-modifier) we download a [raspios_lite_arm64](https://downloads.raspberrypi.com/raspios_lite_arm64/images) image and modify it to install OVOS on top

The images are then uploaded to [github releases](https://github.com/TigreGotico/raspOVOS/releases)

Build Scripts:
- [build_base.sh](build_base.sh) - tunes the base system, installs pipewire, changes user, enables ssh ...
- [build_raspOVOS.sh](build_raspOVOS.sh) - installs OVOS on top of base system (english)
- [build_raspOVOS_gui.sh](build_raspOVOS_gui.sh) - installs OVOS GUI on top of base system
- [build_raspOVOS_ca.sh](build_raspOVOS_ca.sh) - configures OVOS to catalan, installs MatxaTTS

Github Actions:
- [build_base.yml](.github%2Fworkflows%2Fbuild_base.yml) creates `raspOVOS-NO-OVOS-bookworm-arm64-lite.img` [~6 mins build time / ~500 MB]
- [build_img.yml](.github%2Fworkflows%2Fbuild_img.yml) creates `raspOVOS-bookworm-arm64-lite.img` [~30 mins build time / ~1.2 GB]
- [build_img_gui.yml](.github%2Fworkflows%2Fbuild_img_gui.yml) creates `raspOVOS-GUI-bookworm-arm64-lite.img` [~25 mins build time / ~1.33 GB]
- [build_img_ca.yml](.github%2Fworkflows%2Fbuild_img_ca.yml) creates `raspOVOS-catalan-bookworm-arm64-lite.img` [~20 mins build time / ~1.2 GB]
- [build_img_ca_gui.yml](.github%2Fworkflows%2Fbuild_img_ca_gui.yml) creates `raspOVOS-GUI-catalan-bookworm-arm64-lite.img` [~25 mins build time / ~1.33 GB]