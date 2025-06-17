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
bash /mounted-github-repo/lang_builds/lite/build_raspOVOS_pt.sh

# Activate the virtual environment
source /home/$OVOS_USER/.venvs/ovos/bin/activate

echo "Configuring for target language..."
/home/$OVOS_USER/.venvs/ovos/bin/ovos-config autoconfigure --lang pt-PT --hybrid --male

echo "Installing Piper TTS..."
uv pip install --no-progress ovos-tts-plugin-piper -c $CONSTRAINTS

# download default piper voice for dutch
PIPER_DIR="/home/$OVOS_USER/.local/share/piper_tts"
VOICE_URL="https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/pt/pt_PT/tugão/medium/pt_PT-tugão-medium.onnx?download=true"
CONFIG_URL="https://huggingface.co/rhasspy/piper-voices/resolve/v1.0.0/pt/pt_PT/tugão/medium/pt_PT-tugão-medium.onnx.json?download=true"

mkdir -p "$PIPER_DIR"
echo "Downloading voice from $VOICE_URL..."
wget "$VOICE_URL" -P "$PIPER_DIR"
wget "$CONFIG_URL" -P "$PIPER_DIR"

echo "Ensuring permissions for $OVOS_USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$OVOS_USER
