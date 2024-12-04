#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

# Update package list and install necessary tools
echo "Installing system packages..."
apt-get install -y --no-install-recommends i2c-tools fbi swig mpv libssl-dev libfann-dev portaudio19-dev libpulse-dev python3-dev python3-pip

# splashscreen
echo "Creating OVOS splashscreen..."
mkdir -p /opt/ovos
cp -v /mounted-github-repo/services/splashscreen.png /opt/ovos/splashscreen.png
cp -v /mounted-github-repo/services/splashscreen.service /etc/systemd/system/splashscreen.service
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
cp -v /mounted-github-repo/tuning/.bashrc /home/$USER/.bashrc
cp -v /mounted-github-repo/tuning/.bash_aliases /home/$USER/.bash_aliases
cp -v /mounted-github-repo/tuning/.cli_login.sh /home/$USER/.cli_login.sh

echo "Creating system level mycroft.conf..."
cp -v /mounted-github-repo/mycroft.conf /etc/mycroft/mycroft.conf

echo "Downloading constraints.txt from $CONSTRAINTS..."
# TODO - this path will change soon, currently used by ggwave installer to not allow skills to downgrade packages
DEST="/etc/mycroft/constraints.txt"
wget -O "$DEST" "$CONSTRAINTS"

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

echo "Installing ovos-bus-client on host to allow signals..."
pip install ovos-bus-client --break-system-packages -c $CONSTRAINTS

echo "Adding ntp sync signal..."
# emit "system.clock.synced" to the bus
mkdir -p /etc/systemd/system/systemd-timesyncd.service.d/
cp -v /mounted-github-repo/services/ovos-clock-sync.service /etc/systemd/system/systemd-timesyncd.service.d/ovos-clock-sync.conf
cp -v /mounted-github-repo/services/ovos-clock-sync /usr/libexec/ovos-clock-sync

echo "Adding ssh enabled/disabled signals..."
mkdir -p /etc/systemd/system/ssh.service.d
cp -v /mounted-github-repo/services/ovos-ssh-signal.service /etc/systemd/system/ssh.service.d/ovos-ssh-change-signal.conf
cp -v /mounted-github-repo/services/ovos-ssh-disabled-signal /usr/libexec/ovos-ssh-disabled-signal
cp -v /mounted-github-repo/services/ovos-ssh-enabled-signal /usr/libexec/ovos-ssh-enabled-signal

echo "Adding shutdown/reboot signals..."
cp -v /mounted-github-repo/services/ovos-reboot-signal.service /etc/systemd/system/ovos-reboot-signal.service
cp -v /mounted-github-repo/services/ovos-shutdown-signal.service /etc/systemd/system/ovos-shutdown-signal.service
ln -s /etc/systemd/system/ovos-reboot-signal.service /etc/systemd/system/multi-user.target.wants/ovos-reboot-signal.service
ln -s /etc/systemd/system/ovos-shutdown-signal.service /etc/systemd/system/multi-user.target.wants/ovos-shutdown-signal.service
cp -v /mounted-github-repo/services/ovos-restart-signal /usr/libexec/ovos-restart-signal
cp -v /mounted-github-repo/services/ovos-reboot-signal /usr/libexec/ovos-reboot-signal
cp -v /mounted-github-repo/services/ovos-shutdown-signal /usr/libexec/ovos-shutdown-signal

echo "Installing OVOS Rust Messagebus..."
bash /mounted-github-repo/tuning/setup_rustbus.sh

# Create virtual environment for ovos
echo "Creating virtual environment..."
mkdir -p /home/$USER/.venvs
python3 -m venv /home/$USER/.venvs/ovos

# Activate the virtual environment
source /home/$USER/.venvs/ovos/bin/activate

# install OVOS in venv
echo "Installing OVOS..."
pip3 install wheel cython sdnotify
pip3 install ovos-docs-viewer tflite_runtime ovos-core[lgpl,plugins,skills-audio,skills-essential,skills-internet,skills-media,skills-extra] ovos-dinkum-listener[extras,linux,onnx] ovos-phal[extras,linux] ovos-audio[extras] -c $CONSTRAINTS

echo "Installing OVOS ggwave..."
pip3 install -U -f https://whl.smartgic.io/ ggwave
pip3 install ovos-audio-transformer-plugin-ggwave -c $CONSTRAINTS

# TODO - once it works properly
#echo "Installing OVOS Spotifyd..."
#bash /mounted-github-repo/tuning/setup_spotify.sh

echo "Installing Balena wifi plugin..."
pip3 install ovos-PHAL-plugin-balena-wifi ovos-PHAL-plugin-wifi-setup

echo "Downloading default wake word model..."
# Download precise-lite model
wget https://github.com/OpenVoiceOS/precise-lite-models/raw/master/wakewords/en/hey_mycroft.tflite -P /home/$USER/.local/share/precise_lite/

echo "Setting up systemd..."
# copy system scripts over
cp -v /mounted-github-repo/services/ovos-systemd-skills /usr/libexec/ovos-systemd-skills
cp -v /mounted-github-repo/services/ovos-systemd-messagebus /usr/libexec/ovos-systemd-messagebus
cp -v /mounted-github-repo/services/ovos-systemd-audio /usr/libexec/ovos-systemd-audio
cp -v /mounted-github-repo/services/ovos-systemd-listener /usr/libexec/ovos-systemd-listener
cp -v /mounted-github-repo/services/ovos-systemd-phal /usr/libexec/ovos-systemd-phal
cp -v /mounted-github-repo/services/ovos-systemd-gui /usr/libexec/ovos-systemd-gui
cp -v /mounted-github-repo/services/ovos-systemd-admin-phal /usr/libexec/ovos-systemd-admin-phal

mkdir -p /home/$USER/.config/systemd/user/
cp -v /mounted-github-repo/services/ovos.service /home/$USER/.config/systemd/user/
cp -v /mounted-github-repo/services/ovos-skills.service /home/$USER/.config/systemd/user/
cp -v /mounted-github-repo/services/ovos-messagebus.service /home/$USER/.config/systemd/user/
cp -v /mounted-github-repo/services/ovos-audio.service /home/$USER/.config/systemd/user/
cp -v /mounted-github-repo/services/ovos-listener.service /home/$USER/.config/systemd/user/
cp -v /mounted-github-repo/services/ovos-phal.service /home/$USER/.config/systemd/user/
cp -v /mounted-github-repo/services/ovos-gui.service /home/$USER/.config/systemd/user/
cp -v /mounted-github-repo/services/ovos-ggwave.service /home/$USER/.config/systemd/user/
cp -v /mounted-github-repo/services/ovos-admin-phal.service /etc/systemd/system/

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


echo "Ensuring permissions for $USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$USER

echo "Cleaning up apt packages..."
apt-get --purge autoremove -y && apt-get clean