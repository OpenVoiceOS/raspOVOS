#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

## Intended to run on top of the raspOVOS LITE image

: "${OVOS_USER:=ovos}"
: "${CONSTRAINTS:=https://github.com/OpenVoiceOS/ovos-releases/raw/refs/heads/main/constraints-alpha.txt}"

# start from lite image
bash /mounted-github-repo/lang_builds/lite/build_raspOVOS_gl.sh

# Activate the virtual environment
source /home/$OVOS_USER/.venvs/ovos/bin/activate

echo "Configuring for target language..."
/home/$OVOS_USER/.venvs/ovos/bin/ovos-config autoconfigure --lang gl-ES --hybrid --female

echo "Downloading NOS TTS voices..."
mkdir -p /home/$OVOS_USER/.local/share/nos_tts_models/sabela
wget https://huggingface.co/Jarbas/proxectonos-sabela-vits-phonemes-onnx/resolve/main/config.json -P /home/$OVOS_USER/.local/share/nos_tts_models/sabela
wget https://huggingface.co/Jarbas/proxectonos-sabela-vits-phonemes-onnx/resolve/main/model.onnx -P /home/$OVOS_USER/.local/share/nos_tts_models/sabela
mkdir -p /home/$OVOS_USER/.local/share/nos_tts_models/celtia
wget https://huggingface.co/Jarbas/proxectonos-celtia-vits-graphemes-onnx/resolve/main/model.onnx -P /home/$OVOS_USER/.local/share/nos_tts_models/celtia
wget https://huggingface.co/Jarbas/proxectonos-celtia-vits-graphemes-onnx/resolve/main/config.json -P /home/$OVOS_USER/.local/share/nos_tts_models/celtia

# TODO local cotovia binary
uv pip install --no-progress ovos-tts-plugin-cotovia ovos-tts-plugin-nos -c $CONSTRAINTS

echo "Ensuring permissions for $OVOS_USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$OVOS_USER
