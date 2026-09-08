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
bash /mounted-github-repo/lang_builds/hybrid/build_raspOVOS_da.sh

# Activate the virtual environment
source /home/$OVOS_USER/.venvs/ovos/bin/activate
export UV_CONSTRAINT="${CONSTRAINTS:-}" PIP_CONSTRAINT="${CONSTRAINTS:-}" UV_PRERELEASE=allow

echo "Configuring for target language..."
/home/$OVOS_USER/.venvs/ovos/bin/ovos-config autoconfigure --lang de-DE --offline --male --platform rpi5

echo "Installing onnx-asr STT plugin (selected by offline recommends)..."
uv pip install --no-progress ovos-stt-plugin-onnx-asr -c $CONSTRAINTS

echo "Installing phoonnx TTS plugin (selected by offline recommends)..."
uv pip install --no-progress phoonnx -c $CONSTRAINTS

echo "Downloading base whisper model ..."
python -c "from huggingface_hub import snapshot_download; repo_id = 'Systran/faster-whisper-base'; file_path = snapshot_download(repo_id=repo_id); print(f'Downloaded {repo_id}')"
# since script was run as root, we need to move downloaded files
mv /root/.cache/huggingface/hub/models--Systran--faster-whisper-base/ /home/ovos/.cache/huggingface/hub/models--Systran--faster-whisper-base/

echo "Ensuring permissions for $OVOS_USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$OVOS_USER

echo "Updating build manifest..."
LANG_CODE=da bash /mounted-github-repo/scripts/write_build_manifest.sh offline
