#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

## Intended to run on top of the raspOVOS LITE image

: "${OVOS_USER:=ovos}"
: "${CONSTRAINTS:=https://github.com/OpenVoiceOS/OpenVoiceOS/raw/refs/heads/main/constraints-alpha.txt}"

# start from lite image
bash /mounted-github-repo/lang_builds/lite/build_raspOVOS_ca.sh

# Activate the virtual environment
source /home/$OVOS_USER/.venvs/ovos/bin/activate
export UV_CONSTRAINT="${CONSTRAINTS:-}" PIP_CONSTRAINT="${CONSTRAINTS:-}"

echo "Configuring for target language..."
/home/$OVOS_USER/.venvs/ovos/bin/ovos-config autoconfigure --lang ca-ES --hybrid --male --platform rpi4

echo "Downloading model2vec intent model ..."
python -c "from huggingface_hub import hf_hub_download; repo_id='Jarbas/ovos-model2vec-intents-roberta-large-ca-v2-massive'; files=['model.safetensors', 'tokenizer.json', 'config.json']; [print(f'Downloaded {file} to {hf_hub_download(repo_id=repo_id, filename=file)}') for file in files]"
# since script was run as root, we need to move downloaded files
mkdir -p /home/ovos/.cache/huggingface/hub/
mv /root/.cache/huggingface/hub/models--Jarbas--ovos-model2vec-intents-roberta-large-ca-v2-massive/ /home/ovos/.cache/huggingface/hub/models--Jarbas--ovos-model2vec-intents-roberta-large-ca-v2-massive/

# install matxa
echo "Installing Matxa TTS..."
# TODO matxa on pypi does not include the model need to git clone for now
git clone https://github.com/OpenVoiceOS/ovos-tts-plugin-matxa-multispeaker-cat /home/$OVOS_USER/.ovos-tts-plugin-matxa-multispeaker-cat
uv pip install --no-progress -e /home/$OVOS_USER/.ovos-tts-plugin-matxa-multispeaker-cat -c $CONSTRAINTS

echo "Compiling latest espeak..."  # needed for matxa TTS phonemization
apt-get install -y jq automake libtool
git clone https://github.com/espeak-ng/espeak-ng.git /tmp/espeak-ng
cd /tmp/espeak-ng
./autogen.sh  && ./configure && make && make install
rm -rf /tmp/espeak-ng
cd /home/$OVOS_USER/

echo "Ensuring permissions for $OVOS_USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$OVOS_USER

echo "Updating build manifest..."
LANG_CODE=ca bash /mounted-github-repo/scripts/write_build_manifest.sh hybrid
