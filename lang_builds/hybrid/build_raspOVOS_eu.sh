#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

## Intended to run on top of the raspOVOS FULL image

: "${OVOS_USER:=ovos}"
: "${CONSTRAINTS:=https://github.com/OpenVoiceOS/OpenVoiceOS/raw/refs/heads/main/constraints-alpha.txt}"

# start from lite image
bash /mounted-github-repo/lang_builds/lite/build_raspOVOS_eu.sh

# Activate the virtual environment
source /home/$OVOS_USER/.venvs/ovos/bin/activate
export UV_CONSTRAINT="${CONSTRAINTS:-}" PIP_CONSTRAINT="${CONSTRAINTS:-}" UV_PRERELEASE=allow

echo "Configuring for target language..."
/home/$OVOS_USER/.venvs/ovos/bin/ovos-config autoconfigure --lang eu-ES --hybrid --female --platform rpi4

echo "Downloading model2vec intent model ..."
python -c "from huggingface_hub import hf_hub_download; repo_id='Jarbas/ovos-model2vec-intents-BERnaT-base'; files=['model.safetensors', 'tokenizer.json', 'config.json']; [print(f'Downloaded {file} to {hf_hub_download(repo_id=repo_id, filename=file)}') for file in files]"
# since script was run as root, we need to move downloaded files
mkdir -p /home/ovos/.cache/huggingface/hub/
mv /root/.cache/huggingface/hub/models--Jarbas--ovos-model2vec-intents-BERnaT-base/ /home/ovos/.cache/huggingface/hub/models--Jarbas--ovos-model2vec-intents-BERnaT-base/

# TTS engine per tier: offline keeps the AhoTTS voice; hybrid installs what
# autoconfigure selects (phoonnx).
if [[ "${RASPOVOS_TIER:-hybrid}" == "offline" ]]; then
    echo "Installing AhoTTS"
    uv pip install --no-progress ovos-tts-plugin-ahotts
else
    echo "Installing phoonnx TTS plugin (selected by hybrid autoconfigure)..."
    uv pip install --no-progress phoonnx -c $CONSTRAINTS
fi

echo "Ensuring permissions for $OVOS_USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$OVOS_USER

echo "Updating build manifest..."
LANG_CODE=eu bash /mounted-github-repo/scripts/write_build_manifest.sh hybrid
