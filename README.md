# RaspOVOS

Using [dtcooper/rpi-image-modifier](https://github.com/dtcooper/rpi-image-modifier), we download a [raspios_lite_arm64](https://downloads.raspberrypi.com/raspios_lite_arm64/images) image and modify it to install OVOS on top. The customized images are then uploaded to [GitHub Releases](https://github.com/OpenVoiceOS/raspOVOS/releases). 🎉

## 📋 Notes:
- **Default user**: `ovos`  
- **Default password**: `ovos`  
- **Default hostname**: `raspOVOS`  
- OVOS services run under the `ovos` user, with autologin enabled.

> ⚠️ **WARNING**: This repository is a work in progress to replace the [old-raspOVOS](https://github.com/OpenVoiceOS/ZZZ-raspOVOS) built on top of `pigen`. If this warning is still here, the images do not yet have feature parity!

### 📂 Latest Images:
Find the latest images on the [Releases](https://github.com/OpenVoiceOS/raspOVOS/releases) page.  

### 🛠️ Getting Started:
Check out the [Getting Started Guide](https://github.com/OpenVoiceOS/raspOVOS/blob/master/tutorial.md) for instructions.


---

## Language Specific Image Comparison

- 🌟 **Best**: Fully offline (STT, TTS, wake words).
- ✅ **Good**: Online STT + Offline TTS.
- ⚡ **Usable**: Online STT + Online TTS.
- 🛠️ **Work in Progress**: Missing key functionality or early-stage development.

| **Language**   | **STT**                                                  | **TTS**                                            | **Wake Word**                                  | **"Wake Up" Hotword**               | **Notes**                                                                                                                                                            | **Rating**               |
|----------------|----------------------------------------------------------|----------------------------------------------------|------------------------------------------------|-------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------|
| **English**    | `ovos-stt-plugin-server`<br>Whisper Turbo public servers | `ovos-tts-plugin-piper`<br>voice-en-gb-alan-low    | `ovos-ww-plugin-precise-lite`<br>"hey mycroft" | `ovos-ww-plugin-vosk`<br>"wake up"  | - STT relies on public servers                                                                                                                                       | ✅  **Good**              |
| **Catalan**    | `ovos-stt-plugin-citrinet`<br>AINA Citrinet model        | `ovos-tts-plugin-matxa`<br>MatxaTTS                | `ovos-ww-plugin-precise-lite`<br>"hey mycroft" | `ovos-ww-plugin-vosk`<br>"desperta" | - Fully offline; supports Catalan-specific models for STT and TTS.                                                                                                   | 🌟  **Best**             |
| **Portuguese** | `ovos-stt-plugin-server`<br>MyNorthAI public servers     | `ovos-tts-plugin-piper`<br>tugao-medium            | `ovos-ww-plugin-precise-lite`<br>"hey mycroft" | `ovos-ww-plugin-vosk`<br>"acorda"   | - STT relies on public servers<br>- Piper TTS is temporary (poor quality).                                                                                           | ⚡ **Usable**             |
| **Spanish**    | `ovos-stt-plugin-server`<br>Whisper Turbo public servers | `ovos-tts-plugin-ahotts`<br>spanish                | `ovos-ww-plugin-precise-lite`<br>"hey mycroft" | `ovos-ww-plugin-vosk`<br>"desperta" | - STT relies on public servers                                                                                                                                       | ✅  **Good**              |
| **Galician**   | `ovos-stt-plugin-server`<br>Whisper Turbo public servers | `ovos-tts-plugin-server`<br>NOS TTS public servers | `ovos-ww-plugin-precise-lite`<br>"hey mycroft" | `ovos-ww-plugin-vosk`<br>"acorda"                                | - STT and TTS rely on public servers<br>- NOS TTS planned for local use once ONNX support is available. <br>- "wake up" model does not have dedicated galician model | ⚡ **Usable**             |
| **Basque**     | `ovos-stt-plugin-server`<br>Whisper Turbo public servers | `ovos-tts-plugin-ahotts`<br>basque                 | `ovos-ww-plugin-precise-lite`<br>"hey mycroft" | None                                | - STT relies on public servers<br>- HiTz STT remote servers support planned<br>- "wake up" model training needed.                                                    | 🛠️ **Work in Progress** |

---

## 🛠️ Build Scripts

### Base System:
- **[build_base.sh](build_base.sh)**  
  - Tunes the base system (see below).  
  - Installs `pipewire`.  
  - Changes user, enables SSH, and more.  

### OVOS Builds:
- **[build_raspOVOS.sh](build_raspOVOS.sh)**  
  Installs OVOS on the base system, including the `"hey mycroft"` wake word.  
- 🚧 **[build_raspOVOS_gui.sh](build_raspOVOS_gui.sh)** 🚧    
  Installs the OVOS GUI on top of the base system.  (**work in progress**)

![image](https://github.com/user-attachments/assets/92bd2a6f-e2d1-47d4-8140-a5b5b4cb7140)

### Language-Specific Builds:
- **[build_raspOVOS_en.sh](build_raspOVOS_en.sh)**  
  Configures OVOS to English, installs the Vosk English model (`"wake up"` wake word), and adds PiperTTS (`voice-en-gb-alan-low`).  
- **[build_raspOVOS_ca.sh](build_raspOVOS_ca.sh)**  
  Configures OVOS to Catalan, downloads AINA citrinet STT model, and installs MatxaTTS.
  - ✔️ fully offline
- 🚧 **[build_raspOVOS_pt.sh](build_raspOVOS_pt.sh)**  
  Configures OVOS to Portuguese, adds the Vosk Portuguese model (`"acorda"` wake word), sets STT to MyNorthAI public servers, and adds PiperTTS (`tugao-medium`).  
  - 🚧 **TODO**: train a proper TTS model, piper is NOT good  
- 🚧 **[build_raspOVOS_es.sh](build_raspOVOS_es.sh)**  
  Configures OVOS to Spanish, adds the Vosk Spanish model (`"desperta"` wake word), and installs AhoTTS.  
- 🚧 **[build_raspOVOS_gl.sh](build_raspOVOS_gl.sh)**  
  Configures OVOS to Galician, adds the Vosk Portuguese model (`"desperta"` wake word) and configures TTS to use NOS TTS Public servers.  
  - **NOTE**: No dedicated Galician model exists for vosk! (🚧 **TODO**: Test if the Spanish model works better / train galician model).
  - 🚧 **TODO**: local NOS TTS once ONNX support is available.  
- 🚧  **[build_raspOVOS_eu.sh](build_raspOVOS_eu.sh)**  
  Configures OVOS to Basque and installs AhoTTS.  
  - 🚧 **TODO**: Add support for Remote HiTz STT servers
  - ⚠️ No`"wake up"` hotword because no dedicated Basque model exists for vosk! (🚧 **TODO**: train basque model).
  - ⚠️ wont be able to get out of sleep mode if you use naptime skill 

The workflows account for each language/platform combination
![image](https://github.com/user-attachments/assets/22c4ce7e-478a-4ef5-96e8-6e2f7c55ffff)

---

## 🚀 OVOS Raspberry Pi Optimizations

This repository includes scripts to optimize Raspberry Pi OS for running OVOS, improving system performance and stability.

Here is an overview of the changes to the base raspios-lite image

| Script File            | Description                                                                                                                                         | Benefit for Hardware Performance                                                                                                                                                                                                                                            |
|------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `build_base.sh`        | Reduces GPU memory, enables i2c/spi, enables autologin, changes user name, calls scripts below                                                      | optimizes the base system to run OVOS                                                                                                                                                                                                                                       |
| `setup_pipewire.sh`    | Installs PipeWire for sound server management, configures user permissions for audio groups, and sets up `.asoundrc` for default audio handling.    | Provides a low-latency audio server for audio management, ensuring smooth and high-quality sound handling.                                                                                                                                                                  |
| `setup_kdeconnect.sh`  | Installs KDEConnect to enable integration with your phone                                                                                           | Easy file and clipboard sharing                                                                                                                                                                                                                                             |
| `setup_fstab.sh`       | Updates `/etc/fstab` to include `noatime` and `nodiratime` options, reducing disk I/O by not updating access times on reads.                        | Reduces unnecessary disk operations, leading to faster system performance and reduced wear on SD cards.                                                                                                                                                                     |
| `setup_nmanager.sh`    | Configures NetworkManager settings to disable Wi-Fi power-saving and grants the "network" group permission to change settings.                      | Ensures consistent network connectivity and performance, avoiding interruptions or delays that may affect latency.                                                                                                                                                          |
| `setup_sysctl.sh`      | Configures kernel tuning parameters for improved network and memory performance, optimizing system responsiveness for real-time tasks.              | **Improves network and memory performance**: Faster network response, better memory management for smoother operation.                                                                                                                                                      |
|                        | - `net.ipv4.tcp_slow_start_after_idle=0`: Disables slow start for idle TCP connections.                                                             | Reduces latency when establishing new connections, enhancing real-time communication                                                                                                                                                                                        |
|                        | - `net.ipv4.tcp_tw_reuse=1`: Enables reuse of TIME_WAIT sockets.                                                                                    | Reduces time delays for connections by allowing reuse of sockets, benefiting long-running services                                                                                                                                                                          |
|                        | - `net.core.netdev_max_backlog=50000`: Increases the maximum number of packets that can be queued for processing.                                   | Improves network packet processing, reducing latency during high network activity.                                                                                                                                                                                          |
|                        | - `net.ipv4.tcp_max_syn_backlog=30000`: Increases the maximum backlog of pending TCP connections.                                                   | Ensures the system can handle more incoming TCP connections, improving network stability for real-time tasks.                                                                                                                                                               |
|                        | - `net.ipv4.tcp_max_tw_buckets=2000000`: Increases the maximum number of TCP connections in TIME_WAIT state.                                        | Helps manage a higher number of concurrent connections, reducing connection delays in a busy network environment.                                                                                                                                                           |
|                        | - `net.core.rmem_max=16777216`, `net.core.wmem_max=16777216`: Increases maximum buffer sizes for receiving and sending data.                        | Optimizes network throughput by allocating more memory for buffer handling.                                                                                                                                                                                                 |
|                        | - `net.core.rmem_default=16777216`, `net.core.wmem_default=16777216`: Sets default buffer sizes for receiving and sending data.                     | Ensures better performance in network communication, reducing potential lag.                                                                                                                                                                                                |
|                        | - `net.ipv4.tcp_rmem="4096 87380 16777216"`, `net.ipv4.tcp_wmem="4096 65536 16777216"`: Configures TCP buffer sizes for receiving and sending data. | Fine-tunes the memory allocation for TCP, enhancing network efficiency.                                                                                                                                                                                                     |
|                        | - `net.core.optmem_max=40960`: Sets maximum size for socket options memory.                                                                         | Reduces delays in setting socket options, improving responsiveness for real-time communication.                                                                                                                                                                             |
|                        | - `fs.inotify.max_user_instances=8192`, `fs.inotify.max_user_watches=524288`: Increases the number of file system watches.                          | Optimizes system performance by allowing more file monitoring, which can benefit real-time data processing tasks.                                                                                                                                                           |
| `setup_udev.sh`        | Configures udev rules for setting I/O scheduler for MMC and USB devices to "none", minimizing latency for disk and removable storage.               | This can reduce latency and improve performance for flash-based storage like MMC and USB devices. Flash storage does not require complex scheduling algorithms because it has no moving parts (like hard drives), so a simpler, more direct I/O approach is more efficient. |
| `setup_wlan0power.sh`  | Copies the `wlan0-power.service` systemd service file to `/etc/systemd/system/` and enables it to manage Wi-Fi power consumption.                   | Reduces power consumption by disabling Wi-Fi power-saving features, which is important for maintaining stable network performance.                                                                                                                                          |
| `setup_zram.sh`        | Installs and configures ZRAM to create compressed swap space in RAM, improving system performance by reducing disk swap usage.                      | Enhances system performance by reducing reliance on slower disk-based swap and utilizing faster RAM for swap, which is especially useful on limited-resource devices like Raspberry Pi.                                                                                     |
|                        | `vm.swappiness=100`                                                                                                                                 | Increases the system's tendency to use swap space (even if there is available RAM), which helps with memory management and reduces disk I/O.                                                                                                                                |
|                        | `vm.page-cluster=0`                                                                                                                                 | Lowers the number of pages to swap at once, making memory swapping more granular and efficient in cases of memory pressure.                                                                                                                                                 |
|                        | `vm.vfs_cache_pressure=500`                                                                                                                         | Reduces pressure on the VFS cache, ensuring more data stays in memory for faster file access, which is important for real-time applications.                                                                                                                                |
|                        | `vm.dirty_background_ratio=1`                                                                                                                       | Reduces the amount of memory that can be used before data is written to disk, ensuring data is written more frequently and preventing memory overload.                                                                                                                      |
|                        | `vm.dirty_ratio=50`                                                                                                                                 | Controls the threshold at which dirty pages (pages that need to be written to disk) trigger writes. A higher value means more data is kept in memory before writing to disk.                                                                                                |


---

## 📦 Additional Notes
- 🎨 **Custom Builds**: Create your own language or feature-specific builds by extending the scripts!  
- 🔗 **Contribute**: Found a bug or have an idea? Open an issue or submit a PR!  
- 💬 **Community**: Join us on [Matrix](https://matrix.to/#/#openvoiceos:matrix.org) to discuss and get support.  
