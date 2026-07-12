# RaspOVOS

raspOVOS is the **flagship OpenVoiceOS experience for the Raspberry Pi**: ready-to-flash images that turn a Pi into a voice assistant.

Using [TigreGotico/rpi-image-modifier](https://github.com/TigreGotico/rpi-image-modifier) (a fork of [dtcooper/rpi-image-modifier](https://github.com/dtcooper/rpi-image-modifier)), we download
a [raspios_lite_arm64](https://downloads.raspberrypi.com/raspios_lite_arm64/images) image and modify it to install OVOS on top. 

<p align="center">
  <img src="https://github.com/OpenVoiceOS/raspOVOS/blob/dev/logo.png?raw=true" alt="raspOVOS Logo" width="200"/>
</p>

The customized images are then uploaded to [GitHub Releases](https://github.com/OpenVoiceOS/raspOVOS/releases). 🎉

---

- [RaspOVOS](#raspovos)
   + [Getting Started](#getting-started)
   + [Important Notes](#important-notes)
   + [Image Variants](#image-variants)
   + [System requirements](#system-requirements)
   + [Language specific plugins and models](#language-specific-plugins-and-models)
* [What raspOVOS Does to Raspberry Pi OS](#what-raspovos-does-to-raspberry-pi-os)
   + [System Configuration](#system-configuration)
   + [System Dependencies](#system-dependencies)
   + [File System Overlays](#file-system-overlays)
   + [Python Environment Setup](#python-environment-setup)
   + [Models and Skill Enhancements](#models-and-skill-enhancements)
   + [Raspberry Pi Optimizations](#raspberry-pi-optimizations)
        
---

### Getting Started

**Full documentation lives at [openvoiceos.github.io/raspOVOS](https://openvoiceos.github.io/raspOVOS/)** —
flashing tutorials, hardware guidance, troubleshooting, and developer docs
(in-repo source: [`docs/`](docs/index.md)).

Find the latest images on the [Releases](https://github.com/OpenVoiceOS/raspOVOS/releases) page.

Every image build is gated by automated static, functional, and boot smoke
tests ([CI tiers](docs/dev/ci-tiers.md)); stable releases additionally pass a
[hardware checklist](docs/dev/release-checklist.md).

---

### Important Notes

- **Default user**: `ovos`
- **Default password**: `ovos`
- **Default hostname**: `raspOVOS`
- OVOS services run under the `ovos` user, with autologin enabled.

> ⚠️ **DO NOT** change the default user when burning the image or you will run into issues

---

### Image Variants

- `lite` images delegate STT and TTS to public servers and have a minimal intents pipeline
- `hybrid` images delegate STT to public servers, run TTS on device and have a balanced intents pipeline
- `offline` images run STT and TTS on device and have a full intents pipeline

> ⚠️ online servers are hosted by volunteers and provided on a **best effort** basis, [latency and uptime](https://openvoiceos.github.io/status) might vary wildly per request

In general the following plugins are used for all images

| image_type | stt-plugin               | tts-plugin             | m2v-intent-model             |
|------------|--------------------------|------------------------|------------------------------|
| offline    | ovos-stt-plugin-citrinet | ovos-tts-plugin-piper  | ovos-model2vec-intents-LaBSE |
| hybrid     | ovos-stt-plugin-server   | ovos-tts-plugin-piper  | ovos-model2vec-intents-LaBSE |
| online     | ovos-stt-plugin-server   | ovos-tts-plugin-server | N/A                          |

---

### System requirements

- `lite` images *might* work in a rpi3
- `hybrid` images recommend at least a rpi4
- `offline` images need at least 4GB RAM, preferably 8GB

> 💡 Please consider self-hosting your own [TTS](https://openvoiceos.github.io/ovos-technical-manual/201-tts_server/) and [STT](https://openvoiceos.github.io/ovos-technical-manual/200-stt_server/) servers in a more powerful device


---

### Language specific plugins and models

The following language specific plugin configurations are used

| lang | tts-plugin                             |
|------|----------------------------------------|
| ca   | ovos-tts-plugin-matxa-multispeaker-cat |
| gl   | ovos-tts-plugin-nos                    |
| eu   | ovos-tts-plugin-ahotts                 |


| lang | stt-plugin                    | stt-model                                   |
|------|-------------------------------|---------------------------------------------|
| da   | ovos-stt-plugin-fasterwhisper | Systran/faster-whisper-base                 |
| gl   | ovos-stt-plugin-fasterwhisper | Jarbas/faster-whisper-base-gl-cv13          |
| eu   | ovos-stt-plugin-fasterwhisper | Jarbas/faster-whisper-base-eu-cv16          |
| es   | ovos-stt-plugin-citrinet      | Jarbas/stt_es_citrinet_512_onnx             |
| ca   | ovos-stt-plugin-citrinet      | neongeckocom/stt_ca_citrinet_512_gamma_0_25 |
| pt   | ovos-stt-plugin-citrinet      | neongeckocom/stt_pt_citrinet_512_gamma_0_25 |
| de   | ovos-stt-plugin-citrinet      | neongeckocom/stt_de_citrinet_512_gamma_0_25 |
| it   | ovos-stt-plugin-citrinet      | neongeckocom/stt_it_citrinet_512_gamma_0_25 |
| nl   | ovos-stt-plugin-citrinet      | neongeckocom/stt_nl_citrinet_512_gamma_0_25 |
| en   | ovos-stt-plugin-citrinet      | neongeckocom/stt_en_citrinet_512_gamma_0_25 |
| fr   | ovos-stt-plugin-citrinet      | neongeckocom/stt_fr_citrinet_512_gamma_0_25 |


| lang | intent-model                                                       |
|------|--------------------------------------------------------------------|
| mul  | ovos-model2vec-intents-LaBSE                                       |
| en   | ovos-model2vec-intents-potion-32M                                  |
| ca   | ovos-model2vec-intents-roberta-large-ca-v2-massive                 |
| gl   | ovos-model2vec-intents-bertinho-gl-base-cased                      |
| eu   | ovos-model2vec-intents-BERnaT-base                                 |
| pt   | ovos-model2vec-intents-serafim-335m-portuguese-pt-sentence-encoder |
| es   | ovos-model2vec-intents-roberta-large-bne                           |

> NOTE: intent models are still undergoing training for some languages and might not actually be shipped yet

---

## What raspOVOS Does to Raspberry Pi OS

raspOVOS is a customization layer for Raspberry Pi OS that transforms a standard base image into a fully functional,
voice-enabled smart assistant platform powered by [OpenVoiceOS (OVOS)](https://openvoiceos.org). Here’s what the
installation script modifies and installs:

---

### System Configuration

**User Customization:**

* Renames the default `pi` user to a custom user (default: `ovos`).
* Updates all references in system files (`/etc/passwd`, `/etc/group`, `/etc/shadow`) and moves the home directory.
* Sets a default password (`ovos`) and ensures it's reflected across boot and login settings.
* Adds the user to critical groups: `sudo`, `audio`, `pipewire`, `rtkit`, and a custom `ovos` group.

**Hostname:**

* Sets a custom hostname (`raspOVOS`).

**Performance Tuning:**

* Modifies `/etc/fstab` via `setup_fstab.sh` to optimize disk usage and performance (e.g., zram swap).

---

### System Dependencies

Installs essential system tools and packages, including:

* **Build and development tools:** `build-essential`, `swig`, `python3-dev`, `libssl-dev`, etc.
* **Audio stack:** `pipewire`, `wireplumber`, `alsa-utils`, `portaudio`, `mpv`, `ffmpeg`, etc.
* **Camera support:** `python3-libcamera`, `python3-kms++`.
* **DLNA/Media support:** `gstreamer`, `libupnp`, `gmediarender`.

---

### File System Overlays

The file overlays introduce services, configs, and utilities specific to the OVOS runtime environment:

```
├── etc
│   ├── modules-load.d/i2c.conf                      # Ensures i2c modules are loaded on boot
│   ├── mycroft/mycroft.conf                         # Default OVOS config optimized for raspberry pi
│   ├── systemd/system/                              # Systemd service units
│   │   ├── i2csound.service                          # I2C audio board init
│   │   ├── ovos-admin-phal.service                   # Enables admin PHAL (root PHAL plugins)
│   │   ├── splashscreen.service                      # Boot splash screen
├── home
│└── ovos
│    ├── nltk_data                                    # Preloaded NLTK tokenizers, corpora, taggers
│    ├── .config
│    │└── mycroft
│    │    └── mycroft.conf                            # language specific configuration 
│    └── .local
│        └── share
│            ├── mycroft
│            │└── word_corrections.json               # ovos-utterance-corrections-plugin config to improve STT
│            └── vosk
│                └── vosk-model-small-xxx             # vosk model for wake word
├── opt/ovos/
│   ├── splashscreen.png                              # OVOS splash image
│   └── tag                                           
├── usr/libexec/                                      # system signals for ovos-bus:
│   ├── ovos-clock-sync                               
│   ├── ovos-i2csound                                 
│   ├── ovos-librespot                                
│   ├── ovos-ocp-*-signal                             
│   ├── ovos-reboot-signal                            
│   ├── ovos-shutdown-signal                          
│   ├── ovos-ssh-*-signal                             
│   ├── ovos-stop                                     
│   ├── ovos-systemd-* (admin, audio, gui, etc.)     # Systemd wrapper launchers for core subsystems
├── usr/local/bin/
│   ├── ovos-*                                         # CLI tools: ovos-update, ovos-help, ovos-reset-brain, etc.
│   └── ls-*                                           # List available STT, TTS, skills, wakewords, etc.
```

These overlays ensure:

* OVOS boots as a system-managed, modular assistant.
* OS-level actions like reboot, shutdown, clock sync, or SSH enable/disable emit OVOS bus messages.
* Splashscreen and audio initialization integrate tightly with boot services.
* Tools like `ovos-update` and `ovos-reset-brain` provide maintenance and troubleshooting from CLI.

---

### Python Environment Setup

* Installs [uv](https://github.com/astral-sh/uv) and `sdnotify` globally.
* Creates a Python virtual environment at `~/.venvs/ovos`.
* Installs core OVOS components and their dependencies inside the venv:
    * `ovos-core`, `ovos-gui`, `ovos-audio`, `ovos-phal`, `ovos-skill-config-tool`, etc.
    * STT/TTS plugins like `ovos-stt-plugin-fasterwhisper`, `ovos-audio-transformer-plugin-ggwave`.

---

### Models and Skill Enhancements

* Downloads and installs:

    * `model2vec` multilingual intent classification model.
    * `fasterwhisper` for fast, lightweight speech-to-text with language detection.

* Sets up Hugging Face shared model cache under the `ovos` user for efficient reuse across plugins.

---

### Raspberry Pi Optimizations

Here is an overview of non-OVOS specific changes to the base raspios-lite image

| Change                     | Description                                                                                                                                         | Benefit for Hardware Performance                                                                                                                                                                                                                                            |
|----------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Base raspiOS image runing  | Reduces GPU memory, enables i2c/spi, enables autologin, change user name...                                                                         | optimizes the base system to run OVOS                                                                                                                                                                                                                                       |
| Install Pipewire           | Installs PipeWire for sound server management, configures user permissions for audio groups, and sets up `.asoundrc` for default audio handling.    | Provides a low-latency audio server for audio management, ensuring smooth and high-quality sound handling.                                                                                                                                                                  |
| Install KDEConnect         | Installs KDEConnect to enable integration with your phone                                                                                           | Easy file and clipboard sharing                                                                                                                                                                                                                                             |
| Tune fstab                 | Updates `/etc/fstab` to include `noatime` and `nodiratime` options, reducing disk I/O by not updating access times on reads.                        | Reduces unnecessary disk operations, leading to faster system performance and reduced wear on SD cards.                                                                                                                                                                     |
| Passwordless nmcli         | Configures NetworkManager settings to disable Wi-Fi power-saving and grants the "network" group permission to change settings.                      | Ensures consistent network connectivity and performance, avoiding interruptions or delays that may affect latency.                                                                                                                                                          |
| Tune sysctl                | Configures kernel tuning parameters for improved network and memory performance, optimizing system responsiveness for real-time tasks.              | **Improves network and memory performance**: Faster network response, better memory management for smoother operation.                                                                                                                                                      |
|                            | - `net.ipv4.tcp_slow_start_after_idle=0`: Disables slow start for idle TCP connections.                                                             | Reduces latency when establishing new connections, enhancing real-time communication                                                                                                                                                                                        |
|                            | - `net.ipv4.tcp_tw_reuse=1`: Enables reuse of TIME_WAIT sockets.                                                                                    | Reduces time delays for connections by allowing reuse of sockets, benefiting long-running services                                                                                                                                                                          |
|                            | - `net.core.netdev_max_backlog=50000`: Increases the maximum number of packets that can be queued for processing.                                   | Improves network packet processing, reducing latency during high network activity.                                                                                                                                                                                          |
|                            | - `net.ipv4.tcp_max_syn_backlog=30000`: Increases the maximum backlog of pending TCP connections.                                                   | Ensures the system can handle more incoming TCP connections, improving network stability for real-time tasks.                                                                                                                                                               |
|                            | - `net.ipv4.tcp_max_tw_buckets=2000000`: Increases the maximum number of TCP connections in TIME_WAIT state.                                        | Helps manage a higher number of concurrent connections, reducing connection delays in a busy network environment.                                                                                                                                                           |
|                            | - `net.core.rmem_max=16777216`, `net.core.wmem_max=16777216`: Increases maximum buffer sizes for receiving and sending data.                        | Optimizes network throughput by allocating more memory for buffer handling.                                                                                                                                                                                                 |
|                            | - `net.core.rmem_default=16777216`, `net.core.wmem_default=16777216`: Sets default buffer sizes for receiving and sending data.                     | Ensures better performance in network communication, reducing potential lag.                                                                                                                                                                                                |
|                            | - `net.ipv4.tcp_rmem="4096 87380 16777216"`, `net.ipv4.tcp_wmem="4096 65536 16777216"`: Configures TCP buffer sizes for receiving and sending data. | Fine-tunes the memory allocation for TCP, enhancing network efficiency.                                                                                                                                                                                                     |
|                            | - `net.core.optmem_max=40960`: Sets maximum size for socket options memory.                                                                         | Reduces delays in setting socket options, improving responsiveness for real-time communication.                                                                                                                                                                             |
|                            | - `fs.inotify.max_user_instances=8192`, `fs.inotify.max_user_watches=524288`: Increases the number of file system watches.                          | Optimizes system performance by allowing more file monitoring, which can benefit real-time data processing tasks.                                                                                                                                                           |
| udev rules                 | Configures udev rules for setting I/O scheduler for MMC and USB devices to "none", minimizing latency for disk and removable storage.               | This can reduce latency and improve performance for flash-based storage like MMC and USB devices. Flash storage does not require complex scheduling algorithms because it has no moving parts (like hard drives), so a simpler, more direct I/O approach is more efficient. |
| Disable Wi-Fi power-saving | Copies the `wlan0-power.service` systemd service file to `/etc/systemd/system/` and enables it to manage Wi-Fi power consumption.                   | Reduces power consumption by disabling Wi-Fi power-saving features, which is important for maintaining stable network performance.                                                                                                                                          |
| Setup ZRAM                 | Installs and configures ZRAM to create compressed swap space in RAM, improving system performance by reducing disk swap usage.                      | Enhances system performance by reducing reliance on slower disk-based swap and utilizing faster RAM for swap, which is especially useful on limited-resource devices like Raspberry Pi.                                                                                     |
|                            | `vm.swappiness=100`                                                                                                                                 | Increases the system's tendency to use swap space (even if there is available RAM), which helps with memory management and reduces disk I/O.                                                                                                                                |
|                            | `vm.page-cluster=0`                                                                                                                                 | Lowers the number of pages to swap at once, making memory swapping more granular and efficient in cases of memory pressure.                                                                                                                                                 |
|                            | `vm.vfs_cache_pressure=500`                                                                                                                         | Reduces pressure on the VFS cache, ensuring more data stays in memory for faster file access, which is important for real-time applications.                                                                                                                                |
|                            | `vm.dirty_background_ratio=1`                                                                                                                       | Reduces the amount of memory that can be used before data is written to disk, ensuring data is written more frequently and preventing memory overload.                                                                                                                      |
|                            | `vm.dirty_ratio=50`                                                                                                                                 | Controls the threshold at which dirty pages (pages that need to be written to disk) trigger writes. A higher value means more data is kept in memory before writing to disk.                                                                                                |

---

