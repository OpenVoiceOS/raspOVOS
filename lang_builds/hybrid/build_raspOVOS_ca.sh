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
export UV_CONSTRAINT="${CONSTRAINTS:-}" PIP_CONSTRAINT="${CONSTRAINTS:-}" UV_PRERELEASE=allow

echo "Configuring for target language..."
/home/$OVOS_USER/.venvs/ovos/bin/ovos-config autoconfigure --lang ca-ES --hybrid --male --platform rpi4

echo "Downloading model2vec intent model ..."
python -c "from huggingface_hub import hf_hub_download; repo_id='Jarbas/ovos-model2vec-intents-roberta-large-ca-v2-massive'; files=['model.safetensors', 'tokenizer.json', 'config.json']; [print(f'Downloaded {file} to {hf_hub_download(repo_id=repo_id, filename=file)}') for file in files]"
# since script was run as root, we need to move downloaded files
mkdir -p /home/ovos/.cache/huggingface/hub/
mv /root/.cache/huggingface/hub/models--Jarbas--ovos-model2vec-intents-roberta-large-ca-v2-massive/ /home/ovos/.cache/huggingface/hub/models--Jarbas--ovos-model2vec-intents-roberta-large-ca-v2-massive/

# install the TTS plugin the configuration names
echo "Installing phoonnx TTS..."
# 'ovos-config autoconfigure --lang ca-ES' writes the module
# 'ovos-tts-plugin-phoonnx' with the voice below. That entry point comes from
# the 'phoonnx' distribution, which also ships the models, so the git clone of
# the old plugin is not needed any more. The old repository is archived and its
# head caps ovos-plugin-manager below 2.2.0, which the constraints file cannot
# satisfy.
# The base image already carries phoonnx, and uv treats that copy as satisfying
# the requirement: a plain install reports "Checked 1 package" and adds neither
# extra. --reinstall-package is what makes the extras arrive. They are not
# decoration: matcha is the engine of the Catalan voice, and espeak is the
# espyak phonemizer that runs when the espeak-ng binary is absent.
uv pip install --no-progress --reinstall-package phoonnx \
  "phoonnx[espeak,matcha]" -c $CONSTRAINTS
# the extras are the reason for the reinstall, so prove they are importable
python -c "import espyak, scipy; print('espyak and scipy OK')"

CA_VOICE="OpenVoiceOS/matxa-cat-multiaccent-wavenext"
echo "Downloading $CA_VOICE ..."
export HF_HOME="/home/$OVOS_USER/.cache/huggingface"
# not 'phoonnx-voices download': on an image that never ran phoonnx that
# command raises DatabaseNotCommitted on its own voice cache, and it exits 0
# when the download fails. The script downloads and then proves the model file.
/home/$OVOS_USER/.venvs/ovos/bin/python \
  /mounted-github-repo/scripts/check_phoonnx_voice.py "$CA_VOICE"

echo "Compiling latest espeak..."  # needed for matxa TTS phonemization
apt-get install -y jq automake libtool
git clone https://github.com/espeak-ng/espeak-ng.git /tmp/espeak-ng
cd /tmp/espeak-ng
./autogen.sh  && ./configure && make && make install
rm -rf /tmp/espeak-ng
cd /home/$OVOS_USER/

# A constraint binds only a package the resolver is asked about, so a package
# this image inherited and no install line names keeps the version the base
# release froze (T-5125). Reconcile before the chown below, because this runs
# as root and writes into the venv, and before the manifest, so the manifest
# records what ships and Tier 2 finds nothing new.
echo "Reconciling inherited packages with the constraints file..."
/home/$OVOS_USER/.venvs/ovos/bin/python \
  /mounted-github-repo/scripts/reconcile_constraints.py "$CONSTRAINTS"

echo "Ensuring permissions for $OVOS_USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$OVOS_USER

echo "Updating build manifest..."
LANG_CODE=ca bash /mounted-github-repo/scripts/write_build_manifest.sh hybrid
