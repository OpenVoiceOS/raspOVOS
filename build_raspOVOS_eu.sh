#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

# Activate the virtual environment
source /home/$OVOS_USER/.venvs/ovos/bin/activate

apt-get install -y cmake

echo "Copying overlays..."
sudo cp -rv /mounted-github-repo/overlays/eu/* /

echo "Setting up default wifi country..."
/usr/bin/raspi-config nonint do_wifi_country ES

echo "Installing AhoTTS"
uv pip install --no-progress ovos-tts-plugin-ahotts

# TODO - setup benchmarks before deploying lang specific model, use multilingual for now
#echo "Downloading basque model2vec intent model ..."
#python -c "from huggingface_hub import hf_hub_download; repo_id='Jarbas/ovos-model2vec-intents-BERnaT-base'; files=['model.safetensors', 'tokenizer.json', 'config.json']; [print(f'Downloaded {file} to {hf_hub_download(repo_id=repo_id, filename=file)}') for file in files]"
# since script was run as root, we need to move downloaded files
#mkdir -p /home/ovos/.cache/huggingface/hub/
#mv /root/.cache/huggingface/hub/models--Jarbas--ovos-model2vec-intents-BERnaT-base/ /home/ovos/.cache/huggingface/hub/models--Jarbas--ovos-model2vec-intents-BERnaT-base/

echo "Ensuring permissions for $OVOS_USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$OVOS_USER

echo "Cleaning up apt packages..."
apt-get --purge autoremove -y && apt-get clean