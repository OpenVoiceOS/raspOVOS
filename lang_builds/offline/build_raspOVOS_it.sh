#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

: "${OVOS_USER:=ovos}"
: "${CONSTRAINTS:=https://github.com/OpenVoiceOS/OpenVoiceOS/raw/refs/heads/main/constraints-alpha.txt}"

## Intended to run on top of the raspOVOS FULL image

# start from hybrid image
bash /mounted-github-repo/lang_builds/hybrid/build_raspOVOS_it.sh

# Activate the virtual environment
source /home/$OVOS_USER/.venvs/ovos/bin/activate
export UV_CONSTRAINT="${CONSTRAINTS:-}" PIP_CONSTRAINT="${CONSTRAINTS:-}" UV_PRERELEASE=allow

echo "Configuring for target language..."
/home/$OVOS_USER/.venvs/ovos/bin/ovos-config autoconfigure --lang it-IT --offline --female --platform rpi5

echo "Installing onnx-asr STT plugin (selected by offline recommends)..."
uv pip install --no-progress ovos-stt-plugin-onnx-asr -c $CONSTRAINTS

echo "Installing phoonnx TTS plugin (selected by offline recommends)..."
uv pip install --no-progress phoonnx -c $CONSTRAINTS

echo "Ensuring permissions for $OVOS_USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$OVOS_USER

echo "Updating build manifest..."
LANG_CODE=it bash /mounted-github-repo/scripts/write_build_manifest.sh offline
