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
bash /mounted-github-repo/lang_builds/lite/build_raspOVOS_ca.sh

# Activate the virtual environment
source /home/$OVOS_USER/.venvs/ovos/bin/activate

echo "Configuring for target language..."
/home/$OVOS_USER/.venvs/ovos/bin/ovos-config autoconfigure --lang ca-ES --hybrid --male

echo "Compiling latest espeak..."  # needed for matxa TTS phonemization
apt-get install -y jq automake libtool
git clone https://github.com/espeak-ng/espeak-ng.git /tmp/espeak-ng
cd /tmp/espeak-ng
./autogen.sh  && ./configure && make && make install
rm -rf /tmp/espeak-ng

# install matxa
echo "Installing Matxa TTS..."
# TODO matxa on pypi does not include the model need to git clone for now
git clone https://github.com/OpenVoiceOS/ovos-tts-plugin-matxa-multispeaker-cat /home/$OVOS_USER/.ovos-tts-plugin-matxa-multispeaker-cat
uv pip install --no-progress -e /home/$OVOS_USER/.ovos-tts-plugin-matxa-multispeaker-cat -c $CONSTRAINTS


echo "Ensuring permissions for $OVOS_USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$OVOS_USER
