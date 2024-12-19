#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

# Activate the virtual environment
source /home/$USER/.venvs/ovos/bin/activate

echo "Setting up default wifi country..."
/usr/bin/raspi-config nonint do_wifi_country ES

echo "Updating splashscreen..."
cp -v /mounted-github-repo/services/splashscreen_ca.png /opt/ovos/splashscreen.png

echo "Caching pre-trained padatious intents..."
mkdir -p /home/$USER/.local/share/mycroft/intent_cache
cp -rv /mounted-github-repo/intent_cache/ca-ES /home/$USER/.local/share/mycroft/intent_cache/

echo "Installing Catalan specific skills"
uv pip install --no-progress ovos-skill-fuster-quotes

echo "Installing Citrinet plugin..."
uv pip install --no-progress ovos-stt-plugin-citrinet

echo "Downloading catalan citrinet model..."
python /mounted-github-repo/packages/download_citrinet_ca.py
# since script was run as root, we need to move downloaded files
mkdir -p /home/ovos/.cache/huggingface/hub/
mv /root/.cache/huggingface/hub/models--projecte-aina--stt-ca-citrinet-512/ /home/ovos/.cache/huggingface/hub/models--projecte-aina--stt-ca-citrinet-512/

# install matxa
echo "Installing Matxa TTS..."
# TODO matxa on pypi does not include the model need to git clone for now
git clone https://github.com/OpenVoiceOS/ovos-tts-plugin-matxa-multispeaker-cat /home/$USER/.ovos-tts-plugin-matxa-multispeaker-cat
uv pip install --no-progress -e /home/$USER/.ovos-tts-plugin-matxa-multispeaker-cat -c $CONSTRAINTS

echo "Compiling latest espeak..."
apt-get install -y jq automake libtool
git clone https://github.com/espeak-ng/espeak-ng.git /tmp/espeak-ng
cd /tmp/espeak-ng
./autogen.sh  && ./configure && make && make install
rm -rf /tmp/espeak-ng

echo "Downloading catalan vosk model..."
# Download and extract VOSK model
VOSK_DIR="/home/$USER/.local/share/vosk"
mkdir -p $VOSK_DIR
wget https://alphacephei.com/vosk/models/vosk-model-small-ca-0.4.zip -P $VOSK_DIR
unzip -o $VOSK_DIR/vosk-model-small-ca-0.4.zip -d $VOSK_DIR
rm $VOSK_DIR/vosk-model-small-ca-0.4.zip

echo "Creating system level mycroft.conf..."
mkdir -p /etc/mycroft

CONFIG_ARGS=""
# Loop through the MYCROFT_CONFIG_FILES variable and append each file to the jq command
IFS=',' read -r -a config_files <<< "$MYCROFT_CONFIG_FILES"
for file in "${config_files[@]}"; do
  CONFIG_ARGS="$CONFIG_ARGS /mounted-github-repo/$file"
done
# Execute the jq command and merge the files into mycroft.conf
jq -s 'reduce .[] as $item ({}; . * $item)' $CONFIG_ARGS > /etc/mycroft/mycroft.conf

echo "Ensuring permissions for $USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$USER

echo "Cleaning up apt packages..."
apt-get --purge autoremove -y && apt-get clean