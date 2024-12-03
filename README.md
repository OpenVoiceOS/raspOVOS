# RaspOVOS

Using [dtcooper/rpi-image-modifier](https://github.com/dtcooper/rpi-image-modifier) we download a [raspios_lite_arm64](https://downloads.raspberrypi.com/raspios_lite_arm64/images) image and modify it to install OVOS on top

The images are then uploaded to [github releases](https://github.com/TigreGotico/raspOVOS/releases)

Notes:
- default user: ovos
- default password: ovos
- default hostname: raspOVOS
- OVOS services run under the OVOS user, autologin is enabled

> **known issue**: if you change the user in rpi-imager it will not have [sudo access](https://github.com/TigreGotico/raspOVOS/issues/14)

Latest images:

- [raspOVOS-bookworm-arm64-lite-2024-11-27](https://github.com/TigreGotico/raspOVOS/releases/tag/raspOVOS-bookworm-arm64-lite-2024-11-27)
- [raspOVOS-catalan-bookworm-arm64-lite-2024-11-27](https://github.com/TigreGotico/raspOVOS/releases/tag/raspOVOS-catalan-bookworm-arm64-lite-2024-11-27)
- [raspOVOS-GUI-bookworm-arm64-lite-2024-11-27](https://github.com/TigreGotico/raspOVOS/releases/tag/raspOVOS-GUI-bookworm-arm64-lite-2024-11-27)

> **TODO**: github workflow to keep these urls up to date automatically

Build Scripts:

- [build_base.sh](build_base.sh)
  - tunes the base system (see below)
  - installs pipewire
  - changes user
  - enables ssh
  - ...
- [build_raspOVOS.sh](build_raspOVOS.sh)
  - installs OVOS on top of base system
  - download `"hey mycroft"` wake word
- [build_raspOVOS_gui.sh](build_raspOVOS_gui.sh)
  - installs OVOS GUI on top of base system
- [build_raspOVOS_en.sh](build_raspOVOS_en.sh)
  - configures OVOS to english
  - downloads Vosk english model (`"wake up"` wake word)
  - downloads PiperTTS (`voice-en-gb-alan-low`) model
- [build_raspOVOS_pt.sh](build_raspOVOS_pt.sh)
  - configures OVOS to portuguese
  -  sets STT to MyNorthAI public servers
  -  downloads Vosk portuguese model (`"acorda"` wake word)
  -  PiperTTS (`tugao-medium`) model
- [build_raspOVOS_es.sh](build_raspOVOS_es.sh)
  - configures OVOS to spanish
  - downloads Vosk spanish model (`"desperta"` wake word)
  - PiperTTS (`carlfm-x-low`) model
- [build_raspOVOS_gl.sh](build_raspOVOS_gl.sh)
  - configures OVOS to galician
  - downloads Vosk portuguese model (`"desperta"`  wake word) (**NOTE**: galician model does not exist!)
  - installs Remote Cotovia TTS (**TODO** replace with NOS TTS once it supports onnx)
- [build_raspOVOS_ca.sh](build_raspOVOS_ca.sh)
  - configures OVOS to catalan
  - sets STT to AINA public servers
  - downloads Vosk catalan model (for `"desperta"` wake word)
  - installs MatxaTTS
- [build_raspOVOS_eu.sh](build_raspOVOS_eu.sh)
   - configures OVOS to basque
   - (**TODO** AhoTTS)
   - (**TODO** Remote HiTz)
   - (**TODO** find "wake up" wake word alternative)

## Github Actions:

- [build_base.yml](.github%2Fworkflows%2Fbuild_base.yml)
  creates `raspOVOS-NO-OVOS-bookworm-arm64-lite.img` [~6 mins build time / ~500 MB]
- [build_img.yml](.github%2Fworkflows%2Fbuild_img.yml)
  creates `raspOVOS-bookworm-arm64-lite.img` [~30 mins build time / ~1.2 GB]
- [build_img_gui.yml](.github%2Fworkflows%2Fbuild_img_gui.yml)
  creates `raspOVOS-GUI-bookworm-arm64-lite.img` [~25 mins build time / ~1.33 GB]
- [build_img_ca.yml](.github%2Fworkflows%2Fbuild_img_ca.yml)
  creates `raspOVOS-catalan-bookworm-arm64-lite.img` [~20 mins build time / ~1.2 GB]
- [build_img_en.yml](.github%2Fworkflows%2Fbuild_img_en.yml)
  creates `raspOVOS-english-bookworm-arm64-lite.img` [~20 mins build time / ~1.2 GB]
- [build_img_es.yml](.github%2Fworkflows%2Fbuild_img_es.yml)
  creates `raspOVOS-spanish-bookworm-arm64-lite.img` [~20 mins build time / ~1.2 GB]
- [build_img_eu.yml](.github%2Fworkflows%2Fbuild_img_eu.yml)
  creates `raspOVOS-basque-bookworm-arm64-lite.img` [~20 mins build time / ~1.2 GB]
- [build_img_pt.yml](.github%2Fworkflows%2Fbuild_img_pt.yml)
  creates `raspOVOS-portuguese-bookworm-arm64-lite.img` [~20 mins build time / ~1.2 GB]
- [build_img_ca_gui.yml](.github%2Fworkflows%2Fbuild_img_ca_gui.yml)
  creates `raspOVOS-GUI-catalan-bookworm-arm64-lite.img` [~25 mins build time / ~1.33 GB]

Whenever we update the base raspios image the workflows will be automatically updated to start from the newly built images
![image](https://github.com/user-attachments/assets/92bd2a6f-e2d1-47d4-8140-a5b5b4cb7140)

The workflows account for each language/platform combination
![image](https://github.com/user-attachments/assets/22c4ce7e-478a-4ef5-96e8-6e2f7c55ffff)

## OVOS Raspberry Pi Image Optimizations

This repository contains scripts designed to optimize Raspberry Pi OS for running OVOS (Open Voice OS), improving
overall system performance and stability.

Here is an overview of the changes to the base raspios-lite image

| Script File            | Description                                                                                                                                         | Benefit for Hardware Performance                                                                                                                                                                                                                                           |
|------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `setup_cpugovernor.sh` | Configures the CPU governor to "performance" mode, ensuring the CPU runs at maximum speed.                                                          | Maximizes CPU performance for tasks that require high CPU load.                                                                                                                                                                                                            |
| `setup_fstab.sh`       | Updates `/etc/fstab` to include `noatime` and `nodiratime` options, reducing disk I/O by not updating access times on reads.                        | Reduces unnecessary disk operations, leading to faster system performance and reduced wear on SD cards.                                                                                                                                                                    |
| `setup_nmanager.sh`    | Configures NetworkManager settings to disable Wi-Fi power-saving and grants the "network" group permission to change settings.                      | Ensures consistent network connectivity and performance, avoiding interruptions or delays that may affect latency.                                                                                                                                                         |
| `setup_pipewire.sh`    | Installs PipeWire for sound server management, configures user permissions for audio groups, and sets up `.asoundrc` for default audio handling.    | Provides a low-latency audio server for audio management, ensuring smooth and high-quality sound handling.                                                                                                                                                                 |
| `setup_ramdisk.sh`     | Creates a ramdisk at `/ramdisk`, and links OVOS-related log files to it to reduce SD card write cycles and improve overall disk I/O performance.    | Offloads log file storage to RAM, reducing the wear on the SD card and improving system performance by minimizing disk I/O.                                                                                                                                                |
| `setup_sysctl.sh`      | Configures kernel tuning parameters for improved network and memory performance, optimizing system responsiveness for real-time tasks.              | **Improves network and memory performance**: Faster network response, better memory management for smoother operation.                                                                                                                                                     |
|                        | - `net.ipv4.tcp_slow_start_after_idle=0`: Disables slow start for idle TCP connections.                                                             | Reduces latency when establishing new connections, enhancing real-time communication                                                                                                                                                                                       |
|                        | - `net.ipv4.tcp_tw_reuse=1`: Enables reuse of TIME_WAIT sockets.                                                                                    | Reduces time delays for connections by allowing reuse of sockets, benefiting long-running services                                                                                                                                                                         |
|                        | - `net.core.netdev_max_backlog=50000`: Increases the maximum number of packets that can be queued for processing.                                   | Improves network packet processing, reducing latency during high network activity.                                                                                                                                                                                         |
|                        | - `net.ipv4.tcp_max_syn_backlog=30000`: Increases the maximum backlog of pending TCP connections.                                                   | Ensures the system can handle more incoming TCP connections, improving network stability for real-time tasks.                                                                                                                                                              |
|                        | - `net.ipv4.tcp_max_tw_buckets=2000000`: Increases the maximum number of TCP connections in TIME_WAIT state.                                        | Helps manage a higher number of concurrent connections, reducing connection delays in a busy network environment.                                                                                                                                                          |
|                        | - `net.core.rmem_max=16777216`, `net.core.wmem_max=16777216`: Increases maximum buffer sizes for receiving and sending data.                        | Optimizes network throughput by allocating more memory for buffer handling.                                                                                                                                                                                                |
|                        | - `net.core.rmem_default=16777216`, `net.core.wmem_default=16777216`: Sets default buffer sizes for receiving and sending data.                     | Ensures better performance in network communication, reducing potential lag.                                                                                                                                                                                               |
|                        | - `net.ipv4.tcp_rmem="4096 87380 16777216"`, `net.ipv4.tcp_wmem="4096 65536 16777216"`: Configures TCP buffer sizes for receiving and sending data. | Fine-tunes the memory allocation for TCP, enhancing network efficiency.                                                                                                                                                                                                    |
|                        | - `net.core.optmem_max=40960`: Sets maximum size for socket options memory.                                                                         | Reduces delays in setting socket options, improving responsiveness for real-time communication.                                                                                                                                                                            |
|                        | - `fs.inotify.max_user_instances=8192`, `fs.inotify.max_user_watches=524288`: Increases the number of file system watches.                          | Optimizes system performance by allowing more file monitoring, which can benefit real-time data processing tasks.                                                                                                                                                          |
| `setup_udev.sh`        | Configures udev rules for setting I/O scheduler for MMC and USB devices to "none", minimizing latency for disk and removable storage.               | This can reduce latency and improve performance for flash-based storage like MMC and USB devices. Flash storage does not require complex scheduling algorithms because it has no moving parts (like hard drives), so a simpler, more direct I/O approach is more efficient. |
| `setup_wlan0power.sh`  | Copies the `wlan0-power.service` systemd service file to `/etc/systemd/system/` and enables it to manage Wi-Fi power consumption.                   | Reduces power consumption by disabling Wi-Fi power-saving features, which is important for maintaining stable network performance.                                                                                                                                         |
| `setup_zram.sh`         | Installs and configures ZRAM to create compressed swap space in RAM, improving system performance by reducing disk swap usage.                      | Enhances system performance by reducing reliance on slower disk-based swap and utilizing faster RAM for swap, which is especially useful on limited-resource devices like Raspberry Pi.                                                                                    |
|                        | `vm.swappiness=100`                                                                                                                                 | Increases the system's tendency to use swap space (even if there is available RAM), which helps with memory management and reduces disk I/O.                                                                                                                               |
|                        | `vm.page-cluster=0`                                                                                                                                 | Lowers the number of pages to swap at once, making memory swapping more granular and efficient in cases of memory pressure.                                                                                                                                                |
|                        | `vm.vfs_cache_pressure=500`                                                                                                                         | Reduces pressure on the VFS cache, ensuring more data stays in memory for faster file access, which is important for real-time applications.                                                                                                                               |
|                        | `vm.dirty_background_ratio=1`                                                                                                                       | Reduces the amount of memory that can be used before data is written to disk, ensuring data is written more frequently and preventing memory overload.                                                                                                                     |
|                        | `vm.dirty_ratio=50`                                                                                                                                 | Controls the threshold at which dirty pages (pages that need to be written to disk) trigger writes. A higher value means more data is kept in memory before writing to disk.                                                                                               |
