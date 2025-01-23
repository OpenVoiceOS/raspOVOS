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
## Intent Issues

### How to debug intent matching

To easily debug intent parsing open a terminal and run `ologs | grep intent` , this will show you live logs related only to intent parsing

then in another terminal send commands with `ovos-say-to "sentence to test"`  (or use your voice)

example output
```bash
(ovos) ovos@raspOVOS:~ $ ologs | grep intent
2025-01-23 16:29:54.299 - skills - ovos_core.intent_services:handle_utterance:416 - INFO - common_qa match: IntentHandlerMatch(match_type='question:action.skill-ovos-wikipedia.openvoiceos', match_data={'phrase': 'Qui és Elon Musk', 'skill_id': 'skill-ovos-wikipedia.openvoiceos', 'answer': "Elon Reeve Musk FRS és un empresari, inversor i magnat conegut pels seus papers clau a l'empresa espacial SpaceX i l'automobilística Tesla, Inc. Les accions i les opinions expressades per Musk l'han convertit en una figura polaritzadora. Després de guanyar al novembre, Trump va anunciar que havia triat Musk per codirigir la junta assessora del nou Departament d'Eficiència Governamental .", 'callback_data': {'answer': "Elon Reeve Musk FRS és un empresari, inversor i magnat conegut pels seus papers clau a l'empresa espacial SpaceX i l'automobilística Tesla, Inc. Les accions i les opinions expressades per Musk l'han convertit en una figura polaritzadora. Després de guanyar al novembre, Trump va anunciar que havia triat Musk per codirigir la junta assessora del nou Departament d'Eficiència Governamental ."}, 'conf': 0.6}, skill_id='skill-ovos-wikipedia.openvoiceos', utterance='Qui és Elon Musk', updated_session=None)
2025-01-23 16:29:54.300 - skills - ovos_core.intent_services:handle_utterance:436 - DEBUG - intent matching took: 1.5732948780059814
2025-01-23 16:34:07.672 - skills - ovos_core.intent_services:handle_utterance:399 - INFO - Parsing utterance: ['quina hora és']
2025-01-23 16:34:07.675 - skills - ovos_core.intent_services:get_pipeline:234 - DEBUG - Session pipeline: ['stop_high', 'converse', 'ocp_high', 'padatious_high', 'adapt_high', 'ocp_medium', 'fallback_high', 'stop_medium', 'adapt_medium', 'padatious_medium', 'adapt_low', 'common_qa', 'fallback_medium', 'fallback_low']
2025-01-23 16:34:07.678 - skills - ovos_core.intent_services:handle_utterance:430 - DEBUG - no match from <bound method StopService.match_stop_high of <ovos_core.intent_services.stop_service.StopService object at 0x7fff2b036310>>
2025-01-23 16:34:07.686 - skills - ovos_core.intent_services:handle_utterance:430 - DEBUG - no match from <bound method ConverseService.converse_with_skills of <ovos_core.intent_services.converse_service.ConverseService object at 0x7fff7159ae50>>
2025-01-23 16:34:07.691 - skills - ovos_core.intent_services:handle_utterance:430 - DEBUG - no match from <bound method OCPPipelineMatcher.match_high of <ocp_pipeline.opm.OCPPipelineMatcher object at 0x7fff26ac3910>>
2025-01-23 16:34:07.696 - skills - ovos_core.intent_services:handle_utterance:416 - INFO - padatious_high match: IntentHandlerMatch(match_type='skill-ovos-date-time.openvoiceos:what.time.is.it.intent', match_data={}, skill_id='skill-ovos-date-time.openvoiceos', utterance='quina hora és', updated_session=None)
2025-01-23 16:34:07.698 - skills - ovos_core.intent_services:handle_utterance:436 - DEBUG - intent matching took: 0.022924184799194336
```

### How to check installed skills

use the `ls-skills` command

example output
```bash
(ovos) ovos@raspOVOS:~ $ ls-skills
[INFO] Listing installed skills for OpenVoiceOS...
[WARNING] Scanning for installed skills. This may take a few moments, depending on the number of installed skills...

The following skills are installed:

['skill-ovos-weather.openvoiceos',
 'ovos-skill-dictation.openvoiceos',
 'skill-ovos-parrot.openvoiceos',
 'ovos-skill-speedtest.openvoiceos',
 'ovos-skill-ip.openvoiceos',
 'skill-ovos-spelling.openvoiceos',
 'ovos-skill-iss-location.openvoiceos',
 'skill-ovos-audio-recording.openvoiceos',
 'skill-ovos-wordnet.openvoiceos',
 'ovos-skill-days-in-history.openvoiceos',
 'ovos-skill-confucius-quotes.openvoiceos',
 'skill-ovos-fallback-chatgpt.openvoiceos',
 'ovos-skill-alerts.openvoiceos',
 'skill-ovos-local-media.openvoiceos',
 'skill-ovos-volume.openvoiceos',
 'ovos-skill-wikihow.openvoiceos',
 'ovos-skill-personal.OpenVoiceOS',
 'ovos-skill-number-facts.openvoiceos',
 'skill-ovos-hello-world.openvoiceos',
 'ovos-skill-moviemaster.openvoiceos',
 'skill-ovos-date-time.openvoiceos',
 'skill-ovos-fallback-unknown.openvoiceos',
 'ovos-skill-pyradios.openvoiceos',
 'skill-ovos-icanhazdadjokes.openvoiceos',
 'ovos-skill-cmd.forslund',
 'ovos-skill-spotify.openvoiceos',
 'skill-ovos-randomness.openvoiceos',
 'skill-ovos-naptime.openvoiceos',
 'skill-ovos-wikipedia.openvoiceos',
 'skill-ovos-boot-finished.openvoiceos',
 'ovos-skill-camera.openvoiceos',
 'skill-ovos-ddg.openvoiceos',
 'ovos-skill-laugh.openvoiceos',
 'skill-ovos-somafm.openvoiceos',
 'skill-ovos-news.openvoiceos',
 'skill-ovos-wolfie.openvoiceos',
 'ovos-skill-fuster-quotes.openvoiceos']
[SUCCESS] Skill listing completed.
```

### How to check available intents

Skills can optionally provide metadata, if they do instructions will be available under `ovos-commands`

Example output (in catalan)
```bash
(ovos) ovos@raspOVOS:~ $ ovos-commands 
##########################
OpenVoiceOS - Skills help
##########################

Scanning skills...
Found 37 installed skills
Skill ids:
0) - skill-ovos-weather.openvoiceos
1) - ovos-skill-dictation.openvoiceos
2) - skill-ovos-parrot.openvoiceos
3) - ovos-skill-speedtest.openvoiceos
4) - ovos-skill-ip.openvoiceos
5) - skill-ovos-spelling.openvoiceos
6) - ovos-skill-iss-location.openvoiceos
7) - skill-ovos-audio-recording.openvoiceos
8) - skill-ovos-wordnet.openvoiceos
9) - ovos-skill-days-in-history.openvoiceos
10) - ovos-skill-confucius-quotes.openvoiceos
11) - skill-ovos-fallback-chatgpt.openvoiceos
12) - ovos-skill-alerts.openvoiceos
13) - skill-ovos-local-media.openvoiceos
14) - skill-ovos-volume.openvoiceos
15) - ovos-skill-wikihow.openvoiceos
16) - ovos-skill-personal.OpenVoiceOS
17) - ovos-skill-number-facts.openvoiceos
18) - skill-ovos-hello-world.openvoiceos
19) - ovos-skill-moviemaster.openvoiceos
20) - skill-ovos-date-time.openvoiceos
21) - skill-ovos-fallback-unknown.openvoiceos
22) - ovos-skill-pyradios.openvoiceos
23) - skill-ovos-icanhazdadjokes.openvoiceos
24) - ovos-skill-cmd.forslund
25) - ovos-skill-spotify.openvoiceos
26) - skill-ovos-randomness.openvoiceos
27) - skill-ovos-naptime.openvoiceos
28) - skill-ovos-wikipedia.openvoiceos
29) - skill-ovos-boot-finished.openvoiceos
30) - ovos-skill-camera.openvoiceos
31) - skill-ovos-ddg.openvoiceos
32) - ovos-skill-laugh.openvoiceos
33) - skill-ovos-somafm.openvoiceos
34) - skill-ovos-news.openvoiceos
35) - skill-ovos-wolfie.openvoiceos
36) - ovos-skill-fuster-quotes.openvoiceos
Select skill number: 36

Skill name: ovos-skill-fuster-quotes.openvoiceos
Description: La cita del dia de Fuster
Usage examples:
    - La frase del Fuster del dia
    - Necessito alguna idea fusteriana
    - Algun pensament fusterià?
    - Digue’m un aforisme del Fuster
    - Què diria Joan Fuster, aquí?
    - Vull sentir un aforisme fusterià
    - Què diu en Fuster?
    - Què pensen els fusterians?
    - Digues-me alguna cosa fusteriana
```

---

### How to remove all skills

If you want to revert OVOS to a blank state you can use `ovos-reset-brain` to remove ALL skills

example output
```bash
(ovos) ovos@raspOVOS:~ $ ovos-reset-brain 
[INFO] Starting OpenVoiceOS skill uninstallation process...
WARNING: This will uninstall all installed skills. Do you want to continue? (y/n): y
Using Python 3.11.2 environment at: .venvs/ovos
[INFO] The following skills will be uninstalled:
- ovos-skill-alerts
- ovos-skill-audio-recording
- ovos-skill-boot-finished
- ovos-skill-camera
- ovos-skill-cmd
- ovos-skill-confucius-quotes
- ovos-skill-date-time
- ovos-skill-days-in-history
- ovos-skill-dictation
- ovos-skill-fallback-unknown
- ovos-skill-fuster-quotes
- ovos-skill-hello-world
- ovos-skill-icanhazdadjokes
- ovos-skill-ip
- ovos-skill-iss-location
- ovos-skill-laugh
- ovos-skill-local-media
- ovos-skill-moviemaster
- ovos-skill-naptime
- ovos-skill-number-facts
- ovos-skill-parrot
- ovos-skill-personal
- ovos-skill-pyradios
- ovos-skill-randomness
- ovos-skill-somafm
- ovos-skill-speedtest
- ovos-skill-spelling
- ovos-skill-spotify
- ovos-skill-volume
- ovos-skill-weather
- ovos-skill-wikihow
- ovos-skill-wikipedia
- skill-ddg
- skill-news
- skill-ovos-fallback-chatgpt
- skill-wolfie
- skill-wordnet
[INFO] Uninstalling skills...
Using Python 3.11.2 environment at: .venvs/ovos
Uninstalled 37 packages in 513ms
 - ovos-skill-alerts==0.1.15
 - ovos-skill-audio-recording==0.2.5a5
 - ovos-skill-boot-finished==0.4.9
 - ovos-skill-camera==1.0.3a4
 - ovos-skill-cmd==0.2.8
 - ovos-skill-confucius-quotes==0.1.11a1
 - ovos-skill-date-time==0.4.6
 - ovos-skill-days-in-history==0.3.9
 - ovos-skill-dictation==0.2.10
 - ovos-skill-fallback-unknown==0.1.6a2
 - ovos-skill-fuster-quotes==0.0.1
 - ovos-skill-hello-world==0.1.11a4
 - ovos-skill-icanhazdadjokes==0.3.2
 - ovos-skill-ip==0.2.7a1
 - ovos-skill-iss-location==0.2.10
 - ovos-skill-laugh==0.2.1a3
 - ovos-skill-local-media==0.2.9
 - ovos-skill-moviemaster==0.0.8a4
 - ovos-skill-naptime==0.3.12a1
 - ovos-skill-number-facts==0.1.10
 - ovos-skill-parrot==0.1.14
 - ovos-skill-personal==0.1.9
 - ovos-skill-pyradios==0.1.5a1
 - ovos-skill-randomness==0.1.2a1
 - ovos-skill-somafm==0.1.5
 - ovos-skill-speedtest==0.3.3a4
 - ovos-skill-spelling==0.2.6a3
 - ovos-skill-spotify==0.1.9
 - ovos-skill-volume==0.1.13a2
 - ovos-skill-weather==0.1.14
 - ovos-skill-wikihow==0.2.14
 - ovos-skill-wikipedia==0.6.0a1
 - skill-ddg==0.1.15
 - skill-news==0.1.12
 - skill-ovos-fallback-chatgpt==0.1.12
 - skill-wolfie==0.3.0
 - skill-wordnet==0.1.1
[SUCCESS] All skills have been uninstalled successfully.
[WARNING] Note: This operation only deletes the skills. Configuration files and pipeline plugins (which still influence intent matching) are NOT affected by this action.
```

## Wake Word Issues

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

The performance of Vosk may vary depending on the wake word you choose. Some wake words may work better than
others, so it’s essential to test and evaluate the plugin with your chosen word.

Some wake words are hard to trigger, especially if missing from the language model vocabulary

> e.g. `hey mycroft` is usually transcribed as `hey microsoft`,

example for "hey  computer"
```json
  "listener": {
    "wake_word": "hey_computer"
  },
  "hotwords": {
    "hey_computer": {
        "module": "ovos-ww-plugin-vosk",
        "lang": "en",
        "listen": true,
        "debug": true,
        "samples": ["hey computer", "a computer", "hey computed"],
        "rule": "equals",
        "full_vocab": false,
    }
  }
```

- `lang` - lang code for model, optional, will use global value if not set. only used to download models
- `debug` - if true will print extra info, like the transcription contents, useful for adjusting "samples"
- `rule` - how to process the transcript for detections
    - `contains` - if the transcript contains any of provided samples 
    - `equals` - if the transcript exactly matches any of provided samples 
    - `starts` - if the transcript starts with any of provided samples 
    - `ends` - if the transcript ends with any of provided samples 
    - `fuzzy` - fuzzy match transcript against samples
- `samples` - list of samples to match the rules against, optional, by default uses keyword name
- `full_vocab` - use the full language model vocabulary for transcriptions, if false (default) will run in keyword mode

> 💡 `"lang"` does not need to match the main language, if there is no vosk model for your language you can try faking it with similar sounding words from a different one



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

0. **Run Diagnostics script:**
    - raspOVOS includes a helper script `ovos-audio-diagnostics` that will print basic info about your sound system
    - **Example output:**
      ```bash
      (ovos) ovos@raspOVOS:~ $ ovos-audio-diagnostics
      =========================== 
      raspOVOS Audio Diagnostics
      ===========================
    
      # Detected sound server:
      pipewire
    
      # Available audio outputs:
      36 - Built-in Audio Stereo [vol: 0.40]
      45 - Built-in Audio Stereo [vol: 0.85]
      46 - Built-in Audio Digital Stereo (HDMI) [vol: 0.40]

      # Default audio output:
      ID: 36
      NAME: WM8731 HiFi wm8731-hifi-0
      CARD NUMBER: 2
      CARD NAME: snd_rpi_proto
      ```
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

5. **Confirm available audio sinks:**
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