#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

# Update package list and install necessary tools
echo "Installing system packages..."
apt-get install -y --no-install-recommends i2c-tools fbi swig mpv libssl-dev libfann-dev portaudio19-dev libpulse-dev python3-dev python3-pip

echo "Installing KDEConnect..."
apt-get install -y --no-install-recommends kdeconnect
cp -v /mounted-github-repo/kdeconnect.service /etc/systemd/system/kdeconnect.service
chmod 644 /etc/systemd/system/kdeconnect.service
ln -s /etc/systemd/system/kdeconnect.service /etc/systemd/system/multi-user.target.wants/kdeconnect.service

# splashscreen
echo "Creating OVOS splashscreen..."
mkdir -p /opt/ovos
cp -v /mounted-github-repo/splashscreen.png /opt/ovos/splashscreen.png
cp -v /mounted-github-repo/splashscreen.service /etc/systemd/system/splashscreen.service
chmod 644 /etc/systemd/system/splashscreen.service
ln -s /etc/systemd/system/splashscreen.service /etc/systemd/system/multi-user.target.wants/splashscreen.service

echo "Creating default OVOS XDG paths..."
mkdir -p /home/$USER/.config/mycroft
mkdir -p /home/$USER/.local/share/OpenVoiceOS
mkdir -p /home/$USER/.local/share/mycroft
mkdir -p /home/$USER/.cache/mycroft/
mkdir -p /home/$USER/.cache/ovos_gui/
mkdir -p /etc/mycroft
mkdir -p /etc/OpenVoiceOS

# add bashrc and company
echo "Creating aliases and cli login screen..."
cp -v /mounted-github-repo/.bashrc /home/$USER/.bashrc
cp -v /mounted-github-repo/.bash_aliases /home/$USER/.bash_aliases
cp -v /mounted-github-repo/.cli_login.sh /home/$USER/.cli_login.sh

echo "Creating system level mycroft.conf..."
cp -v /mounted-github-repo/mycroft.conf /etc/mycroft/mycroft.conf

echo "Downloading constraints.txt from $CONSTRAINTS..."
# TODO - this path will change soon, currently used by ggwave installer to not allow skills to downgrade packages
DEST="/etc/mycroft/constraints.txt"
wget -O "$DEST" "$CONSTRAINTS"

# Create virtual environment for ovos
echo "Creating virtual environment..."
mkdir -p /home/$USER/.venvs
python3 -m venv /home/$USER/.venvs/ovos

# Activate the virtual environment
source /home/$USER/.venvs/ovos/bin/activate

# install OVOS in venv
echo "Installing OVOS..."
pip3 install wheel cython sdnotify tflite_runtime
pip3 install ovos-core[lgpl,mycroft,plugins,skills-audio,skills-essential,skills-internet,skills-media,skills-extra] ovos-dinkum-listener[extras,linux,onnx] ovos-phal[extras,linux] -c /etc/mycroft/constraints.txt
pip3 install git+https://github.com/OpenVoiceOS/ovos-docs-viewer

echo "Installing OVOS ggwave..."
pip3 install -U -f https://whl.smartgic.io/ ggwave
pip3 install ovos-audio-transformer-plugin-ggwave

echo "Installing Balena wifi setup..."
cp -v /mounted-github-repo/wifi-connect.bin /usr/local/sbin/wifi-connect
cp -rv /mounted-github-repo/wifi-connect /usr/local/share/
pip3 install ovos-PHAL-plugin-balena-wifi ovos-PHAL-plugin-wifi-setup

echo "Downloading default TTS + wake word models..."
# Download precise-lite model
wget https://github.com/OpenVoiceOS/precise-lite-models/raw/master/wakewords/en/hey_mycroft.tflite -P /home/$USER/.local/share/precise_lite/

# Download and extract VOSK model
VOSK_DIR="/home/$USER/.local/share/vosk"
mkdir -p $VOSK_DIR
wget http://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip -P $VOSK_DIR
unzip -o $VOSK_DIR/vosk-model-small-en-us-0.15.zip -d $VOSK_DIR
rm $VOSK_DIR/vosk-model-small-en-us-0.15.zip

# download default piper voice for english  (change this for other languages)
PIPER_DIR="/home/$USER/.local/share/piper_tts/voice-en-gb-alan-low"
VOICE_URL="https://github.com/rhasspy/piper/releases/download/v0.0.2/voice-en-gb-alan-low.tar.gz"
VOICE_ARCHIVE="$PIPER_DIR/voice-en-gb-alan-low.tar.gz"
mkdir -p "$PIPER_DIR"
echo "Downloading voice from $VOICE_URL..."
wget "$VOICE_URL" -O "$VOICE_ARCHIVE"
tar -xvzf "$VOICE_ARCHIVE" -C "$PIPER_DIR"
rm "$VOICE_ARCHIVE"

echo "Setting up systemd..."
# copy system scripts over
cp -v /mounted-github-repo/ovos-systemd-skills /usr/libexec/ovos-systemd-skills
cp -v /mounted-github-repo/ovos-systemd-messagebus /usr/libexec/ovos-systemd-messagebus
cp -v /mounted-github-repo/ovos-systemd-audio /usr/libexec/ovos-systemd-audio
cp -v /mounted-github-repo/ovos-systemd-listener /usr/libexec/ovos-systemd-listener
cp -v /mounted-github-repo/ovos-systemd-phal /usr/libexec/ovos-systemd-phal
cp -v /mounted-github-repo/ovos-systemd-gui /usr/libexec/ovos-systemd-gui
cp -v /mounted-github-repo/ovos-systemd-admin-phal /usr/libexec/ovos-systemd-admin-phal

mkdir -p /home/$USER/.config/systemd/user/
cp -v /mounted-github-repo/ovos.service /home/$USER/.config/systemd/user/
cp -v /mounted-github-repo/ovos-skills.service /home/$USER/.config/systemd/user/
cp -v /mounted-github-repo/ovos-messagebus.service /home/$USER/.config/systemd/user/
cp -v /mounted-github-repo/ovos-audio.service /home/$USER/.config/systemd/user/
cp -v /mounted-github-repo/ovos-listener.service /home/$USER/.config/systemd/user/
cp -v /mounted-github-repo/ovos-phal.service /home/$USER/.config/systemd/user/
cp -v /mounted-github-repo/ovos-gui.service /home/$USER/.config/systemd/user/
cp -v /mounted-github-repo/ovos-ggwave.service /home/$USER/.config/systemd/user/
cp -v /mounted-github-repo/ovos-admin-phal.service /etc/systemd/system/

# Set permissions for services
chmod 644 /home/$USER/.config/systemd/user/*.service
chmod 644 /etc/systemd/system/ovos-admin-phal.service

# Enable services manually by creating symbolic links
mkdir -p /home/$USER/.config/systemd/user/default.target.wants/
ln -s /home/$USER/.config/systemd/user/ovos.service /home/$USER/.config/systemd/user/default.target.wants/ovos.service
ln -s /home/$USER/.config/systemd/user/ovos-skills.service /home/$USER/.config/systemd/user/default.target.wants/ovos-skills.service
ln -s /home/$USER/.config/systemd/user/ovos-messagebus.service /home/$USER/.config/systemd/user/default.target.wants/ovos-messagebus.service
ln -s /home/$USER/.config/systemd/user/ovos-audio.service /home/$USER/.config/systemd/user/default.target.wants/ovos-audio.service
ln -s /home/$USER/.config/systemd/user/ovos-listener.service /home/$USER/.config/systemd/user/default.target.wants/ovos-listener.service
ln -s /home/$USER/.config/systemd/user/ovos-phal.service /home/$USER/.config/systemd/user/default.target.wants/ovos-phal.service
ln -s /home/$USER/.config/systemd/user/ovos-gui.service /home/$USER/.config/systemd/user/default.target.wants/ovos-gui.service
ln -s /home/$USER/.config/systemd/user/ovos-ggwave.service /home/$USER/.config/systemd/user/default.target.wants/ovos-ggwave.service
ln -s /etc/systemd/system/ovos-admin-phal.service /etc/systemd/system/multi-user.target.wants/ovos-admin-phal.service

# setup ovos-i2csound
echo "Installing ovos-i2csound..."
git clone https://github.com/OpenVoiceOS/ovos-i2csound /tmp/ovos-i2csound

cp /tmp/ovos-i2csound/i2c.conf /etc/modules-load.d/i2c.conf
cp /tmp/ovos-i2csound/bcm2835-alsa.conf /etc/modules-load.d/bcm2835-alsa.conf
cp /tmp/ovos-i2csound/i2csound.service /etc/systemd/system/i2csound.service
cp /tmp/ovos-i2csound/ovos-i2csound /usr/libexec/ovos-i2csound
cp /tmp/ovos-i2csound/99-i2c.rules /usr/lib/udev/rules.d/99-i2c.rules

chmod 644 /etc/systemd/system/i2csound.service
chmod +x /usr/libexec/ovos-i2csound

ln -s /etc/systemd/system/i2csound.service /etc/systemd/system/multi-user.target.wants/i2csound.service

echo "Ensuring permissions for $USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$USER

echo "Cleaning up apt packages..."
apt-get --purge autoremove -y && apt-get clean