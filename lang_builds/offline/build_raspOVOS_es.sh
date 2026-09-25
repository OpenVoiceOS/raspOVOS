#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

## Intended to run on top of the raspOVOS FULL image
: "${OVOS_USER:=ovos}"
: "${CONSTRAINTS:=https://github.com/OpenVoiceOS/OpenVoiceOS/raw/refs/heads/main/constraints-alpha.txt}"

# start from hybrid image
bash /mounted-github-repo/lang_builds/hybrid/build_raspOVOS_es.sh

# Activate the virtual environment
source /home/$OVOS_USER/.venvs/ovos/bin/activate
export UV_CONSTRAINT="${CONSTRAINTS:-}" PIP_CONSTRAINT="${CONSTRAINTS:-}" UV_PRERELEASE=allow

echo "Configuring for target language..."
/home/$OVOS_USER/.venvs/ovos/bin/ovos-config autoconfigure --lang es-ES --offline --male --platform rpi5

echo "Installing onnx-asr STT plugin (selected by offline recommends)..."
uv pip install --no-progress ovos-stt-plugin-onnx-asr -c $CONSTRAINTS

echo "Installing phoonnx TTS plugin (selected by offline recommends)..."
uv pip install --no-progress phoonnx -c $CONSTRAINTS

echo "Baking the STT model and the TTS voice into the image..."
# The plugins fetch at first use. An offline image must not need the
# network to listen or speak, so the fetch happens here instead.
HF_HOME=/home/$OVOS_USER/.cache/huggingface \
  /home/$OVOS_USER/.venvs/ovos/bin/python /mounted-github-repo/scripts/bake_offline_models.py

echo "Ensuring permissions for $OVOS_USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$OVOS_USER

echo "Updating build manifest..."
LANG_CODE=es bash /mounted-github-repo/scripts/write_build_manifest.sh offline
