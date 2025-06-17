#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e


: "${OVOS_USER:=ovos}"
: "${PASSWORD:=ovos}"
: "${HOSTNAME:=raspOVOS}"
: "${CONSTRAINTS:=https://github.com/OpenVoiceOS/ovos-releases/raw/refs/heads/main/constraints-alpha.txt}"


# Rename the default 'pi' user if the current user is not 'pi'.
# Updates system configurations related to user, home directory, password, and group.
if [ "$OVOS_USER" != "pi" ]; then
  # 1. Change the username in /etc/passwd
  echo "Renaming user in /etc/passwd..."
  sed -i "s/^pi:/$OVOS_USER:/g" "/etc/passwd"

  # 2. Change the group name in /etc/group
  echo "Renaming user in /etc/group..."
  sed -i "s/\bpi\b/$OVOS_USER/g" "/etc/group"

  # 3. Rename the home directory from /home/pi to /home/newuser
  echo "Renaming home directory..."
  # replace "pi"" with "$OVOS_USER" in /etc/passwd
  sed -i "s|pi:|$OVOS_USER:|g" "/etc/passwd"
  mv "/home/pi" "/home/$OVOS_USER"

  # 4. Change ownership of the new home directory
  echo "Updating file ownership..."
  chown -R 1000:1000 "/home/$OVOS_USER"

  # 5. Change the password in /etc/shadow
  echo "Changing user password to $PASSWORD..."
  NEW_HASHED_PASSWORD=$(openssl passwd -6 "$PASSWORD")
  echo "hashed password: $NEW_HASHED_PASSWORD..."
  sed -i "s#^pi:.*#$OVOS_USER:$NEW_HASHED_PASSWORD:18720:0:99999:7:::#g" "/etc/shadow"

  # 6. don't let raspbian force to change username on first boot
  echo "Disabling first boot user setup wizard..."
  echo "$OVOS_USER:$NEW_HASHED_PASSWORD" > /boot/firmware/userconf.txt
  chmod 600 /boot/firmware/userconf.txt

  # 7. Add the new user to the sudo group
  echo "Adding $OVOS_USER to the sudo group..."
  sed -i "/^sudo:/s/pi/$OVOS_USER/" /etc/group

  echo "User has been renamed, added to sudo group, and password updated."
fi

# Function to add a user to a specific group in /etc/group.
# If the group does not exist, it outputs an error message.
# If the user is not already a member of the group, it adds the user.
add_user_to_group() {
    local user=$1
    local group=$2

    # Check if the group exists
    if ! grep -q "^$group:" /etc/group; then
        echo "Group $group doesn't exist"
        return 1
    fi

    # Add the user to the group if not already a member
    if ! grep -q "^$group:.*\b$OVOS_USER\b" /etc/group; then
        echo "Adding $OVOS_USER to $group"
        sed -i "/^$group:/s/$/,$OVOS_USER/" /etc/group
    else
        echo "$OVOS_USER is already in $group"
    fi
}

# Add the current user to the 'ovos' group.
echo "Adding $OVOS_USER to the ovos group..."
# Create the 'ovos' group if it doesn't exist
if ! getent group ovos > /dev/null; then
    groupadd ovos
fi
add_user_to_group $OVOS_USER ovos

# Retrieve the GID of the 'ovos' group
GROUP_FILE="/etc/group"
TGID=$(awk -F: -v group="ovos" '$1 == group {print $3}' "$GROUP_FILE")

# Check if GID was successfully retrieved
if [[ -z "$TGID" ]]; then
    echo "Error: Failed to retrieve GID for group 'ovos'. Exiting..."
    exit 1
fi

echo "The GID for 'ovos' is: $TGID"

# Parse the UID of the current user from /etc/passwd
PASSWD_FILE="/etc/passwd"
TUID=$(awk -F: -v user="$OVOS_USER" '$1 == user {print $3}' "$PASSWD_FILE")

# Check if UID was successfully retrieved
if [[ -z "$TUID" ]]; then
    echo "Error: Failed to retrieve UID for user '$OVOS_USER'. Exiting..."
    exit 1
fi

echo "The UID for '$OVOS_USER' is: $TUID"

# Update package list and install necessary system tools.
# Installs required packages and purges unnecessary ones.
echo "Updating base system..."
apt-get update -y
# NOTE: zram and mpd need to be installed here otherwise the cmd will hang prompting user about replacing files from overlays
apt-get install -y --no-install-recommends jq git unzip curl build-essential fake-hwclock userconf-pi mosh systemd-zram-generator i2c-tools swig python3-dev python3-pip libssl-dev libfann-dev

echo "Installing audio packages..."
apt-get install -y --no-install-recommends pipewire wireplumber pipewire-alsa alsa-utils portaudio19-dev libpulse-dev libasound2-dev mpv ffmpeg flac kdeconnect

echo "Installing camera packages..."
apt install -y --no-install-recommends python3-libcamera python3-kms++ libcap-dev

# Copy raspOVOS overlay to the system.
echo "Copying raspOVOS overlay..."
cp -rv /mounted-github-repo/overlays/base/* /

# Ensure the correct permissions for binaries
chmod +x /usr/libexec/*

# dependencies for DLNA etc
apt-get update && apt-get install -y --no-install-recommends libupnp-dev libgstreamer1.0-dev \
              gstreamer1.0-plugins-base gstreamer1.0-plugins-good \
              gstreamer1.0-libav gstreamer1.0-pipewire gmediarender


# Configure user groups for audio management.
echo "Configuring audio..."
add_user_to_group $OVOS_USER audio
add_user_to_group $OVOS_USER pipewire
if getent group rtkit > /dev/null 2>&1; then
    add_user_to_group $OVOS_USER rtkit
fi

# Modify /etc/fstab for performance optimization.
echo "Tuning /etc/fstab..."
bash /mounted-github-repo/scripts/setup_fstab.sh

#echo "Updating ovos-i2csound and raspovos-audio-setup"
#bash /mounted-github-repo/scripts/update.sh

# Copy raspOVOS overlay to the system.
echo "Copying raspOVOS overlay..."
cp -rv /mounted-github-repo/overlays/base_ovos/* /

# Ensure the correct permissions for binaries
chmod +x /usr/libexec/*
chmod +x /usr/local/bin/*

echo "Download padatious_cache..."
git clone https://github.com/OpenVoiceOS/padatious_cache /home/$OVOS_USER/.local/share/mycroft

# Install dependencies for system OVOS and related tools.
echo "Installing uv and sdnotify..."
pip install sdnotify uv --break-system-packages

# Install admin phal package and its dependencies.
echo "Installing admin phal..."
pip install ovos-bus-client ovos-phal ovos-PHAL-plugin-system -c $CONSTRAINTS --break-system-packages

# Create and activate a virtual environment for OVOS.
echo "Creating virtual environment..."
mkdir -p /home/$OVOS_USER/.venvs
python3 -m venv --system-site-packages /home/$OVOS_USER/.venvs/ovos
source /home/$OVOS_USER/.venvs/ovos/bin/activate

# Install additional Python dependencies within the virtual environment.
uv pip install --no-progress wheel cython -c $CONSTRAINTS

# Install ggwave in the virtual environment.
echo "Installing ggwave..."
# NOTE: update this wheel if python version changes
uv pip install --no-progress https://whl.smartgic.io/ggwave-0.4.2-cp311-cp311-linux_aarch64.whl

# Install OVOS dependencies in the virtual environment.
echo "Installing OVOS..."
uv pip install --no-progress --pre ovos-skill-config-tool ovos-docs-viewer ovos-utils[extras] ovos-dinkum-listener ovos-phal ovos-audio ovos-gui ovos-core[lgpl,plugins] -c $CONSTRAINTS

echo "Installing STT/TTS plugins..."
uv pip install --no-progress --pre ovos-stt-plugin-fasterwhisper ovos-dinkum-listener[extras,linux,onnx] tflite_runtime ovos-audio-transformer-plugin-ggwave ovos-audio[extras] -c $CONSTRAINTS

echo "Installing extra utils..."
uv pip install --no-progress --pre ovos-yaml-editor -c $CONSTRAINTS


# Install essential skills for OVOS.
echo "Installing skills..."
uv pip install --no-progress --pre -r ./mounted-github-repo/skills.list -c $CONSTRAINTS

# Install PHAL plugins for OVOS.
echo "Installing PHAL plugins..."
uv pip install --no-progress --pre ovos-phal[extras,linux,mk1] ovos-PHAL-plugin-dotstar ovos-phal-plugin-camera -c $CONSTRAINTS

# Install Spotify-related plugins for OVOS.
echo "Installing OVOS Spotify..."
uv pip install --no-progress --pre ovos-media-plugin-spotify -c $CONSTRAINTS


# Enable necessary system services.
echo "Enabling system services..."
chmod 644 /etc/systemd/system/kdeconnect.service
chmod 644 /etc/systemd/system/splashscreen.service
chmod 644 /etc/systemd/system/ovos-admin-phal.service
ln -s /etc/systemd/system/ovos-admin-phal.service /etc/systemd/system/multi-user.target.wants/ovos-admin-phal.service
ln -s /etc/systemd/system/splashscreen.service /etc/systemd/system/multi-user.target.wants/splashscreen.service
ln -s /etc/systemd/system/i2csound.service /etc/systemd/system/multi-user.target.wants/i2csound.service
ln -s /etc/systemd/system/autoconfigure_soundcard.service /etc/systemd/system/multi-user.target.wants/autoconfigure_soundcard.service
ln -s /etc/systemd/system/sshd.service /etc/systemd/system/multi-user.target.wants/sshd.service
ln -s /etc/systemd/system/kdeconnect.service /etc/systemd/system/multi-user.target.wants/kdeconnect.service
#ln -s /usr/lib/systemd/system/mpd.service /etc/systemd/system/multi-user.target.wants/mpd.service
ln -s /usr/lib/systemd/system/systemd-zram-setup@.service /etc/systemd/system/multi-user.target.wants/systemd-zram-setup@zram0.service

# Enable user systemd services.
chmod 644 /home/$OVOS_USER/.config/systemd/user/*.service
mkdir -p /home/$OVOS_USER/.config/systemd/user/default.target.wants/
ln -s /home/$OVOS_USER/.config/systemd/user/ovos.service /home/$OVOS_USER/.config/systemd/user/default.target.wants/ovos.service
ln -s /home/$OVOS_USER/.config/systemd/user/ovos-skills.service /home/$OVOS_USER/.config/systemd/user/default.target.wants/ovos-skills.service
ln -s /home/$OVOS_USER/.config/systemd/user/ovos-messagebus.service /home/$OVOS_USER/.config/systemd/user/default.target.wants/ovos-messagebus.service
ln -s /home/$OVOS_USER/.config/systemd/user/ovos-audio.service /home/$OVOS_USER/.config/systemd/user/default.target.wants/ovos-audio.service
ln -s /home/$OVOS_USER/.config/systemd/user/ovos-listener.service /home/$OVOS_USER/.config/systemd/user/default.target.wants/ovos-listener.service
ln -s /home/$OVOS_USER/.config/systemd/user/ovos-phal.service /home/$OVOS_USER/.config/systemd/user/default.target.wants/ovos-phal.service
ln -s /home/$OVOS_USER/.config/systemd/user/ovos-gui.service /home/$OVOS_USER/.config/systemd/user/default.target.wants/ovos-gui.service
ln -s /home/$OVOS_USER/.config/systemd/user/ovos-ggwave.service /home/$OVOS_USER/.config/systemd/user/default.target.wants/ovos-ggwave.service
#ln -s /home/$OVOS_USER/.config/systemd/user/ovos-librespot.service /home/$OVOS_USER/.config/systemd/user/default.target.wants/ovos-librespot.service
#ln -s /home/$OVOS_USER/.config/systemd/user/ovos-spotifyd.service /home/$OVOS_USER/.config/systemd/user/default.target.wants/ovos-spotifyd.service
ln -s /home/$OVOS_USER/.config/systemd/user/ovos-skill-settings-ui.service /home/$OVOS_USER/.config/systemd/user/default.target.wants/ovos-skill-settings-ui.service
ln -s /home/$OVOS_USER/.config/systemd/user/gmrender.service /home/$OVOS_USER/.config/systemd/user/default.target.wants/gmrender.service

echo "Enabling messagebus signals..."
ln -s /etc/systemd/system/ovos-reboot-signal.service /etc/systemd/system/multi-user.target.wants/ovos-reboot-signal.service
ln -s /etc/systemd/system/ovos-shutdown-signal.service /etc/systemd/system/multi-user.target.wants/ovos-shutdown-signal.service

echo "Ensuring log file permissions for ovos group..."
mkdir -p /home/$OVOS_USER/.local/state/mycroft
chown -R $TUID:$TGID /home/$OVOS_USER/.local/state/mycroft
chmod -R 2775 /home/$OVOS_USER/.local/state/mycroft

echo "Ensuring permissions for $OVOS_USER user..."
chmod 644 /home/$OVOS_USER/.asoundrc
chown -R $TUID:$TGID /home/$OVOS_USER

# Enable lingering for the user
echo "Enabling lingering for $OVOS_USER user ..."
mkdir -p /var/lib/systemd/linger
touch /var/lib/systemd/linger/$OVOS_USER
# Ensure correct permissions
chown root:root /var/lib/systemd/linger/$OVOS_USER
chmod 644 /var/lib/systemd/linger/$OVOS_USER

echo "Cleaning up apt packages..."
apt-get --purge autoremove -y && apt-get clean
