#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

: "${OVOS_USER:=ovos}"
: "${CONSTRAINTS:=https://github.com/OpenVoiceOS/ovos-releases/raw/refs/heads/main/constraints-alpha.txt}"

## Intended to run on top of the raspOVOS FULL image

# start from hybrid image
bash /mounted-github-repo/lang_builds/hybrid/build_raspOVOS_it.sh

# Activate the virtual environment
source /home/$OVOS_USER/.venvs/ovos/bin/activate

echo "Configuring for target language..."
/home/$OVOS_USER/.venvs/ovos/bin/ovos-config autoconfigure --lang it-IT --offline --female

echo "Installing Italian Citrinet plugin..."
uv pip install --no-progress ovos-stt-plugin-citrinet -c $CONSTRAINTS

echo "Downloading Italian citrinet model..."
python -c "from huggingface_hub import hf_hub_download; repo_id='neongeckocom/stt_it_citrinet_512_gamma_0_25'; subfolder='onnx'; files=['model.onnx', 'tokenizer.spm', 'preprocessor.ts']; [print(f'Downloaded {file} to {hf_hub_download(repo_id=repo_id, filename=file, subfolder=subfolder)}') for file in files]"
# since script was run as root, we need to move downloaded files
mkdir -p /home/ovos/.cache/huggingface/hub/
mv /root/.cache/huggingface/hub/models--neongeckocom--stt_it_citrinet_512_gamma_0_25/ /home/ovos/.cache/huggingface/hub/models--neongeckocom--stt_it_citrinet_512_gamma_0_25/

echo "Ensuring permissions for $OVOS_USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$OVOS_USER
