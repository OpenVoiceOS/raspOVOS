## Troubleshooting

---

### Undervoltage Detected Warning

If you see an **undervoltage detected** warning:

- Check your power adapter and cable.
- Ensure the adapter can supply enough current (e.g., 5A for Raspberry Pi 5).
- Replace long or thin cables with shorter, thicker ones for better power delivery.

---

### System Boot Issues

- If the device does not complete its boot sequence:
    1. Ensure the power supply is stable and sufficient for your Raspberry Pi model.
    2. If the OS boots but OVOS doesn't work:

    - See if all OVOS services started up correctly with `ovos-status` command
    - Check log files in `~/.local/state/mycroft/` for OVOS error messages.

    3. Re-flash the image if necessary, ensuring all configuration options are set correctly.

---

### OVOS Fails to Speak "I am Ready"

- Confirm the device has a working Internet connection. otherwise OVOS won't consider itself ready

---

## Troubleshooting Wake Word Issues

Wake word detection in raspOVOS offers several options, each with its advantages and limitations. Understanding these
can help resolve potential issues and improve performance.

By default, raspOVOS uses the `precise-lite` model with the wake word "hey mycroft." This model was trained by MycroftAI
for their Mark2 device. However, there are a few things to consider:

- **Microphone Compatibility:** The performance of precise models can be impacted if the specific properties of your
  microphone (e.g., sensitivity, frequency response) do not match the data used to train the model. While the default
  `precise-lite` model was trained with a balanced dataset from a variety of Mycroft users, there is no guarantee it
  will work optimally with your microphone.
- **Speaker Demographics:** Precise models, including `precise-lite`, are often trained with datasets predominantly
  featuring adult male voices. As a result, the model may perform poorly with voices that are outside this demographic,
  such as children's or women's voices. This is a common issue also seen in Speech-to-Text (STT) models.

### Custom Models

If the default model is not working well for you, consider training your own precise model. Here are some helpful
resources for creating a more tailored solution:

- [Helpful Wake Word Datasets on Hugging Face](https://huggingface.co/collections/Jarbas/wake-word-datasets-672cc275fa4bddff9cf69c39)
- [Data Collection](https://github.com/secretsauceai/wakeword-data-collector)
- [Wake Word Trainer](https://github.com/secretsauceai/precise-wakeword-model-maker)
- [precise-lite-trainer Code](https://github.com/OpenVoiceOS/precise-lite-trainer)
- [Synthetic Data Creation for Wake Words](https://github.com/OpenVoiceOS/ovos-ww-auto-synth-dataset)

### Alternative Wake Word: Vosk Plugin

If you're looking for an alternative to the precise model, the Vosk wake word plugin is another option.

- [Vosk Wake Word Plugin GitHub](https://github.com/OpenVoiceOS/ovos-ww-plugin-vosk)

One of the main advantages of using the **Vosk Wake Word Plugin** is that it does **not require a training step**.

Instead, it uses Kaldi with a limited language model, which means it can work out-of-the-box with certain wake words
without needing to collect and train custom data.

However, the performance of Vosk may vary depending on the wake word you choose. Some wake words may work better than
others, so it’s essential to test and evaluate the plugin with your chosen word.

### Tips for Choosing a Good Wake Word

Selecting a wake word is crucial to improving the accuracy and responsiveness of your system. Here are some tips for
choosing a wake word that will work well in various environments:

- **3 or 4 Syllables:** Wake words that are 3 or 4 syllables long tend to perform better because they are more distinct
  and less likely to be confused with common words in everyday speech. For example:
    - **Bad Example:** "Bob" (short, common name)
    - **Less Bad Example:** "Computer" (common word)
    - **Good Example:** "Ziggy" (uncommon)
    - **Better Example:** "Hey Ziggy" (3 syllables, longer)

- **Uncommon Words:** Choose a wake word that is not often used in regular conversation. This reduces the chance of
  false triggers when other words sound similar to your wake word. Unique and uncommon names, phrases, or combinations
  of sounds work best.

- **Clear Pronunciation:** Make sure the wake word has a clear and easy-to-pronounce structure. Words with ambiguous or
  difficult-to-articulate syllables may cause detection issues, especially in noisy environments.

- **Avoid Overused Words:** Stay away from wake words like "hey" or "hello," as they are often used in daily speech and
  can trigger false positives. Try combining a less common word with a familiar greeting for better results.

---

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
    - Run `aplay -l` to list all detected audio playback devices (speakers). Verify your card is being detected
      correctly
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

5. **Confirm default sink:**
    - Run `wpctl status` to check the available outputs as seen by `pipewire`.
    - The default sinks will be marked with `*`
    - You can inspect a sink by its number with `wpctl inspect $SINK_ID`
    - **Example output**:
      ```
      (ovos) ovos@raspOVOS:~ $ wpctl status
      PipeWire 'pipewire-0' [1.2.4, ovos@raspOVOS, cookie:3349583741]
      └─ Clients:
           33. WirePlumber                         [1.2.4, ovos@raspOVOS, pid:695]
           34. WirePlumber [export]                [1.2.4, ovos@raspOVOS, pid:695]
           47. PipeWire ALSA [librespot]           [1.2.4, ovos@raspOVOS, pid:702]
           67. PipeWire ALSA [python3.11]          [1.2.4, ovos@raspOVOS, pid:691]
           75. PipeWire ALSA [python3.11]          [1.2.4, ovos@raspOVOS, pid:699]
           83. PipeWire ALSA [python3.11]          [1.2.4, ovos@raspOVOS, pid:700]
           84. wpctl                               [1.2.4, ovos@raspOVOS, pid:1710]
    
      Audio
      ├─ Devices:
      │      42. Built-in Audio                      [alsa]
      │      43. Built-in Audio                      [alsa]
      │      44. Built-in Audio                      [alsa]
      │  
      ├─ Sinks:
      │  *   36. Built-in Audio Stereo               [vol: 0.40]
      │      45. Built-in Audio Stereo               [vol: 0.85]
      │      46. Built-in Audio Digital Stereo (HDMI) [vol: 0.40]
      │  
      ├─ Sink endpoints:
      │  
      ├─ Sources:
      │  *   37. Built-in Audio Stereo               [vol: 1.00]
      │  
      ├─ Source endpoints:
      │  
      └─ Streams:
           48. PipeWire ALSA [librespot]                                   
                63. output_FL       > WM8731 HiFi wm8731-hifi-0:playback_FL	[active]
                64. output_FR       > WM8731 HiFi wm8731-hifi-0:playback_FR	[active]
           68. PipeWire ALSA [python3.11]                                  
                69. input_FL        < WM8731 HiFi wm8731-hifi-0:capture_FL	[active]
                70. monitor_FL     
                71. input_FR        < WM8731 HiFi wm8731-hifi-0:capture_FR	[active]
                72. monitor_FR              
         
      (ovos) ovos@raspOVOS:~ $ wpctl inspect 36
      id 36, type PipeWire:Interface:Node
           alsa.card = "2"
           alsa.card_name = "snd_rpi_proto"
           alsa.class = "generic"
           alsa.device = "0"
           alsa.driver_name = "snd_soc_rpi_proto"
           alsa.id = "sndrpiproto"
           alsa.long_card_name = "snd_rpi_proto"
           alsa.name = "WM8731 HiFi wm8731-hifi-0"
           alsa.resolution_bits = "16"
           alsa.subclass = "generic-mix"
           alsa.subdevice = "0"
           alsa.subdevice_name = "subdevice #0"
           ...
        ```
      
8. **Test Audio:**
    - Record a short test file with `arecord -f test.wav`.
    - Play it back with `aplay test.wav`.

---

### STT tips and tricks

#### Saving Transcriptions

You can enable saving of recordings to file, this should be your first step to diagnose problems, is the audio
inteligible? is it being cropped? too noisy? low volume?

> set `"save_utterances": true` in
> your [listener config](https://github.com/OpenVoiceOS/ovos-config/blob/V0.0.13a19/ovos_config/mycroft.conf#L436),
> recordings will be saved to `~/.local/share/mycroft/listener/utterances`

If the recorded audio looks good to you, maybe you need to use a different STT plugin, maybe the one you are using does
not like your microphone, or just isn't very good for your language

#### Wrong Transcriptions

If you consistently get specific words or utterances transcribed wrong, you can remedy around this to some extent by
using the [ovos-utterance-corrections-plugin](https://github.com/OpenVoiceOS/ovos-utterance-corrections-plugin)

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

By default OVOS applies VAD (Voice Activity Detection) to crop silence from the audio sent to STT, this helps in
performance and in accuracy (reduces hallucinations in plugins like FasterWhisper)

Depending on your microphone/VAD plugin, this might be removing too much audio

> set `"remove_silence": false` in
> your [listener config](https://github.com/OpenVoiceOS/ovos-config/blob/V0.0.13a19/ovos_config/mycroft.conf#L452), this
> will send the full audio recording to STT

#### Listen Sound

does your listen sound contain speech? some users replace the "ding" sound with words such as "yes?"

In this case the listen sound will be sent to STT and might negatively affect the transcription

> set `"instant_listen": false` in
> your [listener config](https://github.com/OpenVoiceOS/ovos-config/blob/V0.0.13a19/ovos_config/mycroft.conf#L519), this
> will drop the listen sound audio from the STT audio buffer. You will need to wait for the listen sound to finish before
> speaking your command in this case

---