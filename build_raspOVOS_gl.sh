#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

# Activate the virtual environment
source /home/$OVOS_USER/.venvs/ovos/bin/activate

echo "Copying overlays..."
sudo cp -rv /mounted-github-repo/overlays/gl/* /

echo "Setting up default wifi country..."
/usr/bin/raspi-config nonint do_wifi_country ES


# TODO - setup benchmarks before deploying lang specific model, use multilingual for now
#echo "Downloading galician model2vec intent model ..."
#python -c "from huggingface_hub import hf_hub_download; repo_id='Jarbas/ovos-model2vec-intents-bertinho-gl-base-cased'; files=['model.safetensors', 'tokenizer.json', 'config.json']; [print(f'Downloaded {file} to {hf_hub_download(repo_id=repo_id, filename=file)}') for file in files]"
# since script was run as root, we need to move downloaded files
#mkdir -p /home/ovos/.cache/huggingface/hub/
#mv /root/.cache/huggingface/hub/models--Jarbas--ovos-model2vec-intents-bertinho-gl-base-cased/ /home/ovos/.cache/huggingface/hub/models--Jarbas--ovos-model2vec-intents-bertinho-gl-base-cased/

echo "Downloading NOS TTS voices..."
mkdir -p /home/$OVOS_USER/.local/share/nos_tts_models/sabela
wget https://huggingface.co/Jarbas/proxectonos-sabela-vits-phonemes-onnx/resolve/main/config.json -P /home/$OVOS_USER/.local/share/nos_tts_models/sabela
wget https://huggingface.co/Jarbas/proxectonos-sabela-vits-phonemes-onnx/resolve/main/model.onnx -P /home/$OVOS_USER/.local/share/nos_tts_models/sabela
mkdir -p /home/$OVOS_USER/.local/share/nos_tts_models/celtia
wget https://huggingface.co/Jarbas/proxectonos-celtia-vits-graphemes-onnx/resolve/main/model.onnx -P /home/$OVOS_USER/.local/share/nos_tts_models/celtia
wget https://huggingface.co/Jarbas/proxectonos-celtia-vits-graphemes-onnx/resolve/main/config.json -P /home/$OVOS_USER/.local/share/nos_tts_models/celtia

# TODO local cotovia binary
uv pip install --no-progress ovos-tts-plugin-cotovia ovos-tts-plugin-nos ovos-tts-plugin-cotovia-remote -c $CONSTRAINTS

echo "Ensuring permissions for $OVOS_USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$OVOS_USER

echo "Cleaning up apt packages..."
apt-get --purge autoremove -y && apt-get clean