# RaspOVOS: A Beginner's Guide to Setting Up Your Raspberry Pi with OVOS  

This tutorial is designed for users new to Raspberry Pi and RaspOVOS. Follow these steps to set up and optimize your device for the best experience.  

---

## Step 1: Prepare Your Hardware  

### Raspberry Pi Model Recommendations  
- **Recommended:** Raspberry Pi 4 or 5.  
  - For offline STT (speech-to-text), the **Raspberry Pi 5** offers significant performance improvements.  
- **Minimum Requirement:** Raspberry Pi 3.  
  - **Note:** The Raspberry Pi 3 will work but may be **extremely slow** compared to newer models.  

### Storage Options  
- **SD Card or USB Storage:**  
  - You can use either a microSD card or a USB drive.  
- **Recommended:** USB SSD Drive for maximum speed and performance.  
  - Connect the USB drive to the **blue USB 3.0 port** for optimal performance.  

### Power Supply Considerations  
Raspberry Pi boards are notoriously **picky about power supplies**. Insufficient power can lead to performance issues, random reboots, or the appearance of the **undervoltage detected** warning (a lightning bolt symbol in the top-right corner of the screen).  

- **Recommended Power Supplies:**  
  - Raspberry Pi 4: 5V 3A USB-C power adapter.  
  - Raspberry Pi 5: Official Raspberry Pi 5 USB-C power adapter or equivalent high-quality adapter with sufficient current capacity.  
- **Common Issues:**  
  - Using cheap or low-quality chargers or cables may result in voltage drops.  
  - Long or thin USB cables can cause resistance, reducing the power delivered to the board.  
- **How to Fix:**  
  - Always use the official power adapter or a trusted brand with a stable 5V output.  
  - If you see the **"undervoltage detected"** warning, consider replacing your power supply or cable.  

---

## Step 2: Install RaspOVOS Image  

1. **Download and Install Raspberry Pi Imager**  
   - Visit [Raspberry Pi Imager](https://www.raspberrypi.com/software/) and download the appropriate version for your OS.  
   - Install and launch the imager.  

2. **Flash the Image to Storage**  
   - Insert your SD card or USB drive into your computer.  
   - In the Raspberry Pi Imager:  
     - **Choose OS:** Select "Use custom" and locate the RaspOVOS image file.  
     - **Choose Storage:** Select your SD card or USB drive.  


![image](https://github.com/user-attachments/assets/92458289-a3c3-4c7b-afc8-126881445f9f)

![image](https://github.com/user-attachments/assets/36a83d0a-ebc2-4095-94ba-604ad78b5452)

![image](https://github.com/user-attachments/assets/47c92497-d1a2-4f2d-90be-189806736c0d)

3. **Advanced Configuration Options**  
   - Click **Next** and select **Edit Settings** to customize settings, including:  
     - **Password:** Change the default password.  
     - **Hostname:** Set a custom hostname for your device.  
     - **Wi-Fi Credentials:** Enter your Wi-Fi network name and password.  
     - **Keyboard Layout:** Configure the correct layout for your region.  

   **Important:** **Do NOT change the default username** (`ovos`), as it is required for the system to function properly.  

![image](https://github.com/user-attachments/assets/9509ea57-ae46-4c0b-b9e9-97935579d207)

![image](https://github.com/user-attachments/assets/252af1a0-54dc-4450-aa4a-eb0f0a4d139f)

4. **Write the Image**  
   - Click **Save** and then **Yes** to flash the image onto your storage device.  
   - Once complete, safely remove the SD card or USB drive from your computer.  

---

## Step 3: Initial Setup and First Boot  

### Connect and Power On  
- Insert the SD card or connect the USB drive to your Raspberry Pi.  
- Plug in the power supply and connect an HDMI monitor to observe the boot process.  

### First Boot Process  
1. **Initialization:**  
   - The system will expand the filesystem, generate SSH keys, and perform other setups.  
2. **Reboots:**  
   - The device will reboot **up to three times** during this process.  
3. **Autologin:**  
   - The `ovos` user will automatically log in to the terminal after boot.  

4. **Check System Status:**  
   - Use the `ologs` command to monitor logs and confirm that the system has fully initialized.  

---

## Step 4: Setting Up Wi-Fi  

### Option 1: Configure Wi-Fi Using Raspberry Pi Imager  
The most straightforward method is to set up Wi-Fi during the imaging process.  

1. Open Raspberry Pi Imager and select Edit Settings Option.  
2. Enter your **SSID (Wi-Fi network name)** and **password** in the Wi-Fi configuration fields.  
3. Write the image to your SD card or USB drive, and your Wi-Fi will be pre-configured.  

### Option 2: Use Audio-Based Wi-Fi Setup (ggwave)  

1. Open [ggwave Wi-Fi setup](https://openvoiceos.github.io/ovos-audio-transformer-plugin-ggwave/) on a device with speakers.  
2. Enter your **SSID** and **password** and transmit the data as sound.  
3. Place the transmitting device near the Raspberry Pi microphone.  
4. If successful, you’ll hear an acknowledgment tone.  
   - If decoding fails or credentials are incorrect, you’ll hear an error tone.  

🚧 **Note:** ggwave is a **work-in-progress** feature and does not have any dialogs or provide on-screen feedback. 🚧 

![image](https://github.com/user-attachments/assets/ce2857b1-b93f-4092-99f3-43f555e04920)

---

## Step 5: Running OVOS  

### OVOS First Launch  
- On the first run, OVOS may take longer to initialize.  
- When ready, OVOS will say: **"I am ready"** (requires an Internet connection).  

---

## Step 6: Using OVOS Commands  

### Helpful Commands  
Once the terminal appears, you’ll see a guide with OVOS commands. Some key commands include:  

- **Configuration:**  
  - `ovos-config` — Manage configuration files.  
- **Voice Commands:**  
  - `ovos-listen` — Activate the microphone for commands.  
  - `ovos-speak <phrase>` — Make OVOS speak a specific phrase.  
- **Skill Management:**  
  - `ovos-install [PACKAGE_NAME]` — Install OVOS packages.  
  - `ovos-update` — Update all OVOS and skill packages.  
- **Logs and Status:**  
  - `ologs` — View logs in real-time.  
  - `ovos-status` — Check the status of OVOS-related services.  

You use the command `ovos-help` to print the message with all commands again at any point

### Check Logs in Real-Time  
- Use the `ologs` command to monitor logs live on your screen.  
- If you’re unsure whether the system has finished booting, check logs using this command.  

---

## Troubleshooting  

### Undervoltage Detected Warning  

If you see an **undervoltage detected** warning:  
- Check your power adapter and cable.  
- Ensure the adapter can supply enough current (e.g., 5A for Raspberry Pi 5).  
- Replace long or thin cables with shorter, thicker ones for better power delivery.  

### Audio Issues  

1. **Check Input Devices:**  
   - Run `arecord -l` to list all detected audio capture devices (microphones).  
   - **Example output**:    
     ```
     **** List of CAPTURE Hardware Devices ****
     card 2: sndrpiproto [snd_rpi_proto], device 0: WM8731 HiFi wm8731-hifi-0 [WM8731 HiFi wm8731-hifi-0]
      Subdevices: 0/1
      Subdevice #0: subdevice #0
     card 3: Device [USB Audio Device], device 0: USB Audio [USB Audio]
      Subdevices: 1/1
      Subdevice #0: subdevice #0
     ```  

2. **Check Output Devices:**  
   - Run `aplay -l` to list all detected audio playback devices (speakers).  Verify your card is being detected correctly
   - **Example output**:  
     ```
     **** List of PLAYBACK Hardware Devices ****
     card 0: Headphones [bcm2835 Headphones], device 0: bcm2835 Headphones [bcm2835 Headphones]
      Subdevices: 7/8
      Subdevice #0: subdevice #0
      Subdevice #1: subdevice #1
      Subdevice #2: subdevice #2
      Subdevice #3: subdevice #3
      Subdevice #4: subdevice #4
      Subdevice #5: subdevice #5
      Subdevice #6: subdevice #6
      Subdevice #7: subdevice #7
     card 1: vc4hdmi [vc4-hdmi], device 0: MAI PCM i2s-hifi-0 [MAI PCM i2s-hifi-0]
      Subdevices: 1/1
      Subdevice #0: subdevice #0
     card 2: sndrpiproto [snd_rpi_proto], device 0: WM8731 HiFi wm8731-hifi-0 [WM8731 HiFi wm8731-hifi-0]
      Subdevices: 1/1
      Subdevice #0: subdevice #0
     ```
3. **Verify Volume and Mute status:**  
   - Run `alsamixer` and verify that volume isn't too low or audio muted.  

4. **Check audio setup logs:**
   - During boot the audio setup generates logs, which are saved to the `/tmp` directory:
     - `/tmp/autosoundcard.log` (for soundcard autoconfiguration)
     - `/tmp/autovolume-usb.log` (for USB soundcard udev events)
     - `/tmp/autosink.log` (for sink creation and merging events)
     - **Example output**:   
     ```
     ==> /tmp/autosoundcard.log <==
     Fri 17 Jan 11:42:46 WET 2025 - **** List of PLAYBACK Hardware Devices ****
     card 0: Headphones [bcm2835 Headphones], device 0: bcm2835 Headphones [bcm2835 Headphones]
      Subdevices: 8/8
      Subdevice #0: subdevice #0
      Subdevice #1: subdevice #1
      Subdevice #2: subdevice #2
      Subdevice #3: subdevice #3
      Subdevice #4: subdevice #4
      Subdevice #5: subdevice #5
      Subdevice #6: subdevice #6
      Subdevice #7: subdevice #7
     card 1: Device [USB Audio Device], device 0: USB Audio [USB Audio]
      Subdevices: 1/1
      Subdevice #0: subdevice #0
     card 2: vc4hdmi [vc4-hdmi], device 0: MAI PCM i2s-hifi-0 [MAI PCM i2s-hifi-0]
      Subdevices: 1/1
      Subdevice #0: subdevice #0
     card 3: sndrpiproto [snd_rpi_proto], device 0: WM8731 HiFi wm8731-hifi-0 [WM8731 HiFi wm8731-hifi-0]
      Subdevices: 0/1
      Subdevice #0: subdevice #0
     Fri 17 Jan 11:42:48 WET 2025 - Mark 1 soundcard detected by ovos-i2csound.
     Fri 17 Jan 11:42:48 WET 2025 - Detected CARD_NUMBER for Mark 1 soundcard: 3
     Fri 17 Jan 11:42:48 WET 2025 - Configuring ALSA default card
     Fri 17 Jan 11:42:48 WET 2025 - Running as user, modifying ~/.asoundrc
     Fri 17 Jan 11:42:48 WET 2025 - ALSA default card set to: 3
     ```
     ```  
     ==> /tmp/autovolume-usb.log <==
      Subdevices: 1/1
      Subdevice #0: subdevice #0
     card 2: vc4hdmi [vc4-hdmi], device 0: MAI PCM i2s-hifi-0 [MAI PCM i2s-hifi-0]
      Subdevices: 1/1
      Subdevice #0: subdevice #0
     card 3: sndrpiproto [snd_rpi_proto], device 0: WM8731 HiFi wm8731-hifi-0 [WM8731 HiFi wm8731-hifi-0]
      Subdevices: 1/1
      Subdevice #0: subdevice #0
     Fri Jan 17 11:42:43 WET 2025 - USB audio device detected. Soundcard index: 1
     Fri Jan 17 11:42:43 WET 2025 - Volume set to 85% on card 1, control 'Speaker'
     ```   
     ```
     ==> /tmp/autosink.log  <==
     Setting up audio output as combined sinks
     Running as user
     Sinks before action: 52	alsa_output.platform-bcm2835_audio.stereo-fallback	PipeWire	s16le 2ch 48000Hz	SUSPENDED
     53	alsa_output.platform-3f902000.hdmi.hdmi-stereo	PipeWire	s32le 2ch 48000Hz	SUSPENDED
     54	alsa_output.platform-soc_sound.stereo-fallback	PipeWire	s32le 2ch 48000Hz	RUNNING
     56	alsa_output.usb-GeneralPlus_USB_Audio_Device-00.analog-stereo	PipeWire	s16le 2ch 48000Hz	SUSPENDED
     auto_combined sink missing
     Total sinks: 4
     Combined sink created with outputs: alsa_output.platform-bcm2835_audio.stereo-fallback,alsa_output.platform-3f902000.hdmi.hdmi-stereo,alsa_output.platform-soc_sound.stereo-fallback,alsa_output.usb-GeneralPlus_USB_Audio_Device-00.analog-stereo (module ID: 536870916)
     Sinks after action: 52	alsa_output.platform-bcm2835_audio.stereo-fallback	PipeWire	s16le 2ch 48000Hz	SUSPENDED
     53	alsa_output.platform-3f902000.hdmi.hdmi-stereo	PipeWire	s32le 2ch 48000Hz	SUSPENDED
     54	alsa_output.platform-soc_sound.stereo-fallback	PipeWire	s32le 2ch 48000Hz	RUNNING
     56	alsa_output.usb-GeneralPlus_USB_Audio_Device-00.analog-stereo	PipeWire	s16le 2ch 48000Hz	SUSPENDED
     108	auto_combined	PipeWire	float32le 2ch 48000Hz	SUSPENDED
     ```
     
5. **Rerun audio setup script:**
   - Run `ovos-audio-setup` and go through audio setup
    ```bash
       Audio Setup Options:
       1) Manually select default soundcard
       2) Autoconfigure default soundcard
       3) Enable combined audio sinks
       4) Revert changes
       5) Exit 
    ```
6. **Confirm default output sink:**  
   - Run `cat ~/.asoundrc` to check the default soundcard in use, audio might be coming out of a different output (such as onboard audio jack or HDMI).  
     - **Example output** *if combining audio sinks* (option 3 in `ovos-audio-setup`)`:   
     ```
     pcm.!default pipewire
     ctl.!default pipewire
     ```
     - **Example output** *if explicitly selecting soundcard* (option 1+2 in `ovos-audio-setup`)`:  
     ```
     defaults.pcm.card 2
     defaults.ctl.card 2
     ```     
   
7. **Test Audio:**  
   - Record a short test file with `arecord -f test.wav`.  
   - Play it back with `aplay test.wav`.  

### System Boot Issues  
- If the device does not complete its boot sequence:  
  1. Ensure the power supply is stable and sufficient for your Raspberry Pi model.  
  2. If the OS boots but OVOS doesn't work:
    - See if all OVOS services started up correctly with `ovos-status` command
    - Check log files in `~/.local/state/mycroft/` for OVOS error messages.
  3. Re-flash the image if necessary, ensuring all configuration options are set correctly.  

### OVOS Fails to Speak "I am Ready"  
- Confirm the device has a working Internet connection. otherwise OVOS won't consider itself ready 

### STT tips and tricks

#### Saving Transcriptions

You can enable saving of recordings to file, this should be your first step to diagnose problems, is the audio inteligible? is it being cropped? too noisy? low volume?

> set `"save_utterances": true` in your [listener config](https://github.com/OpenVoiceOS/ovos-config/blob/V0.0.13a19/ovos_config/mycroft.conf#L436), recordings will be saved to `~/.local/share/mycroft/listener/utterances`

If the recorded audio looks good to you, maybe you need to use a different STT plugin, maybe the one you are using does not like your microphone, or just isn't very good for your language

#### Wrong Transcriptions

If you consistently get specific words or utterances transcribed wrong, you can remedy around this to some extent by using the [ovos-utterance-corrections-plugin](https://github.com/OpenVoiceOS/ovos-utterance-corrections-plugin)

> You can define replacements at word level `~/.local/share/mycroft/word_corrections.json`

for example whisper STT often gets artist names wrong, this allows you to correct them
```json
{
    "Jimmy Hendricks": "Jimi Hendrix",
    "Eric Klapptern": "Eric Clapton",
    "Eric Klappton": "Eric Clapton"
}
```

#### Silence Removal

By default OVOS applies VAD (Voice Activity Detection) to crop silence from the audio sent to STT, this helps in performance and in accuracy (reduces hallucinations in plugins like FasterWhisper)

Depending on your microphone/VAD plugin, this might be removing too much audio

> set `"remove_silence": false` in your [listener config](https://github.com/OpenVoiceOS/ovos-config/blob/V0.0.13a19/ovos_config/mycroft.conf#L452), this will send the full audio recording to STT

#### Listen Sound

does your listen sound contain speech? some users replace the "ding" sound with words such as "yes?"

In this case the listen sound will be sent to STT and might negatively affect the transcription

> set `"instant_listen": false` in your [listener config](https://github.com/OpenVoiceOS/ovos-config/blob/V0.0.13a19/ovos_config/mycroft.conf#L519), this will drop the listen sound audio from the STT audio buffer. You will need to wait for the listen sound to finish before speaking your command in this case

---

Enjoy your journey with RaspOVOS! With your Raspberry Pi set up, you can start exploring all the features of OpenVoiceOS.
