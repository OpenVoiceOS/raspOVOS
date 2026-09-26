#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

## Intended to run on top of the raspOVOS LITE image

: "${OVOS_USER:=ovos}"
: "${CONSTRAINTS:=https://github.com/OpenVoiceOS/OpenVoiceOS/raw/refs/heads/main/constraints-alpha.txt}"

# start from lite image
bash /mounted-github-repo/lang_builds/lite/build_raspOVOS_ca.sh

# Activate the virtual environment
source /home/$OVOS_USER/.venvs/ovos/bin/activate
export UV_CONSTRAINT="${CONSTRAINTS:-}" PIP_CONSTRAINT="${CONSTRAINTS:-}" UV_PRERELEASE=allow

echo "Configuring for target language..."
/home/$OVOS_USER/.venvs/ovos/bin/ovos-config autoconfigure --lang ca-ES --hybrid --male --platform rpi4

echo "Downloading model2vec intent model ..."
python -c "from huggingface_hub import hf_hub_download; repo_id='Jarbas/ovos-model2vec-intents-roberta-large-ca-v2-massive'; files=['model.safetensors', 'tokenizer.json', 'config.json']; [print(f'Downloaded {file} to {hf_hub_download(repo_id=repo_id, filename=file)}') for file in files]"
# since script was run as root, we need to move downloaded files
mkdir -p /home/ovos/.cache/huggingface/hub/
mv /root/.cache/huggingface/hub/models--Jarbas--ovos-model2vec-intents-roberta-large-ca-v2-massive/ /home/ovos/.cache/huggingface/hub/models--Jarbas--ovos-model2vec-intents-roberta-large-ca-v2-massive/

# install the TTS plugin autoconfigure selects for ca-ES
# ovos-tts-plugin-matxa-multispeaker-cat is archived, and its own README is a
# migration guide to phoonnx. Its dev head caps ovos-plugin-manager <2.2.0,
# which constraints-alpha.txt (>=2.12.5a1) cannot satisfy, so the clone made uv
# report "No solution found" and Catalan was the only build that failed.
# phoonnx declares the ovos-tts-plugin-phoonnx entry point that
# recommends/offline_male/ca-es.conf names, and it serves the same matxa
# acoustic model and vocoder.
echo "Installing phoonnx TTS..."
uv pip install --no-progress phoonnx -c $CONSTRAINTS

echo "Compiling latest espeak..."  # the matxa voice phonemizes with espeak
apt-get install -y jq automake libtool
git clone https://github.com/espeak-ng/espeak-ng.git /tmp/espeak-ng
cd /tmp/espeak-ng
./autogen.sh  && ./configure && make && make install
rm -rf /tmp/espeak-ng
cd /home/$OVOS_USER/

# Pre-download the voice the configuration names, so the image speaks offline.
# HF_HOME points at the ovos user's cache: the voice files land where the
# running service reads them, and the chown below gives them to that user.
CA_VOICE="OpenVoiceOS/matxa-cat-multiaccent-wavenext"
export HF_HOME="/home/$OVOS_USER/.cache/huggingface"
echo "Downloading the Catalan voice $CA_VOICE ..."
/home/$OVOS_USER/.venvs/ovos/bin/phoonnx-voices download "$CA_VOICE"

# phoonnx-voices download prints a network failure and exits 0, so the download
# alone is not proof. Load the voice and speak one sentence: the build fails if
# a file is missing, if onnxruntime cannot load the graph on arm64, or if
# espeak phonemization is broken.
echo "Verifying the Catalan voice loads and speaks ..."
CA_VOICE="$CA_VOICE" /home/$OVOS_USER/.venvs/ovos/bin/python - <<'PYCHECK'
import os
import wave
from phoonnx.config import SynthesisConfig
from phoonnx.model_manager import TTSModelManager

voice_id = os.environ["CA_VOICE"]
wav_path = "/home/ovos/.cache/ca-voice-check.wav"
manager = TTSModelManager()
manager.load()
manager.merge_default_voices()
info = manager.get_voice(voice_id)
if info is None:
    raise SystemExit(f"voice {voice_id} is not in the phoonnx voice index")
voice = info.load()
with wave.open(wav_path, "wb") as f:
    # speaker_id 2 is what recommends/offline_male/ca-es.conf selects
    voice.synthesize_wav("Bon dia, com estas?", f,
                         SynthesisConfig(speaker_id=2))
size = os.path.getsize(wav_path)
os.remove(wav_path)
if size < 1024:
    raise SystemExit(f"{voice_id} wrote only {size} bytes of audio")
print(f"{voice_id} spoke {size} bytes of audio")
PYCHECK

echo "Ensuring permissions for $OVOS_USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$OVOS_USER

echo "Updating build manifest..."
LANG_CODE=ca bash /mounted-github-repo/scripts/write_build_manifest.sh hybrid
