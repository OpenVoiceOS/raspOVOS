#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

## Intended to run on top of the raspOVOS FULL image

: "${OVOS_USER:=ovos}"
: "${CONSTRAINTS:=https://github.com/OpenVoiceOS/OpenVoiceOS/raw/refs/heads/main/constraints-alpha.txt}"

# Activate the virtual environment
source /home/$OVOS_USER/.venvs/ovos/bin/activate
export UV_CONSTRAINT="${CONSTRAINTS:-}" PIP_CONSTRAINT="${CONSTRAINTS:-}"

echo "Copying overlays..."
sudo cp -rv /mounted-github-repo/overlays/en/* /
sudo cp -rv /mounted-github-repo/overlays/mul/* /

echo "Downloading model2vec intent model ..."
python -c "from huggingface_hub import hf_hub_download; repo_id='Jarbas/ovos-model2vec-intents-LaBSE'; files=['model.safetensors', 'tokenizer.json', 'config.json']; [print(f'Downloaded {file} to {hf_hub_download(repo_id=repo_id, filename=file)}') for file in files]"
# since script was run as root, we need to move downloaded files
mkdir -p /home/ovos/.cache/huggingface/hub/
mv /root/.cache/huggingface/hub/models--Jarbas--ovos-model2vec-intents-LaBSE/ /home/ovos/.cache/huggingface/hub/models--Jarbas--ovos-model2vec-intents-LaBSE/

echo "Installing Plugins..."
# TODO: find offline multilingual model
# google is here as placeholder as we dont want to load too many piper voices into memory
uv pip install --no-progress ovos-tts-plugin-google-tx -c $CONSTRAINTS

echo "Ensuring permissions for $OVOS_USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$OVOS_USER

echo "Cleaning up apt packages..."
apt-get --purge autoremove -y && apt-get clean
echo "Updating build manifest..."
LANG_CODE=mul bash /mounted-github-repo/scripts/write_build_manifest.sh hybrid
