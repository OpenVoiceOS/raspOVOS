#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

: "${OVOS_USER:=ovos}"
: "${CONSTRAINTS:=https://github.com/OpenVoiceOS/ovos-releases/raw/refs/heads/main/constraints-alpha.txt}"

# Activate the virtual environment
source /home/$OVOS_USER/.venvs/ovos/bin/activate

echo "Copying overlays..."
sudo cp -rv /mounted-github-repo/overlays/pt/* /

echo "Setting up default wifi country..."
/usr/bin/raspi-config nonint do_wifi_country PT

echo "Installing Portuguese specific skills"
uv pip install --no-progress ovos-core[skills-pt] -c $CONSTRAINTS

echo "Installing Citrinet plugin..."
uv pip install --no-progress ovos-stt-plugin-citrinet -c $CONSTRAINTS

# TODO - setup benchmarks before deploying lang specific model, use multilingual for now
#echo "Downloading portuguese model2vec intent model ..."
#python -c "from huggingface_hub import hf_hub_download; repo_id='Jarbas/ovos-model2vec-intents-serafim-335m-portuguese-pt-sentence-encoder'; files=['model.safetensors', 'tokenizer.json', 'config.json']; [print(f'Downloaded {file} to {hf_hub_download(repo_id=repo_id, filename=file)}') for file in files]"
# since script was run as root, we need to move downloaded files
#mkdir -p /home/ovos/.cache/huggingface/hub/
#mv /root/.cache/huggingface/hub/models--Jarbas--ovos-model2vec-intents-serafim-335m-portuguese-pt-sentence-encoder/ /home/ovos/.cache/huggingface/hub/models--Jarbas--ovos-model2vec-intents-serafim-335m-portuguese-pt-sentence-encoder/


echo "Downloading portuguese citrinet model..."
python -c "from huggingface_hub import hf_hub_download; repo_id='neongeckocom/stt_pt_citrinet_512_gamma_0_25'; subfolder='onnx'; files=['model.onnx', 'tokenizer.spm', 'preprocessor.ts']; [print(f'Downloaded {file} to {hf_hub_download(repo_id=repo_id, filename=file, subfolder=subfolder)}') for file in files]"
# since script was run as root, we need to move downloaded files
mkdir -p /home/ovos/.cache/huggingface/hub/
mv /root/.cache/huggingface/hub/models--neongeckocom--stt_pt_citrinet_512_gamma_0_25/ /home/ovos/.cache/huggingface/hub/models--neongeckocom--stt_pt_citrinet_512_gamma_0_25/

echo "Installing Edge TTS..." # TODO: no decent offline pt voices :(
uv pip install --no-progress ovos-tts-plugin-edge-tts -c $CONSTRAINTS

echo "Ensuring permissions for $OVOS_USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$OVOS_USER

echo "Cleaning up apt packages..."
apt-get --purge autoremove -y && apt-get clean