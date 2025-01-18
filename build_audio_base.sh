#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

# Rename the default 'pi' user if the current user is not 'pi'.
# Updates system configurations related to user, home directory, password, and group.
if [ "$USER" != "pi" ]; then
  # 1. Change the username in /etc/passwd
  echo "Renaming user in /etc/passwd..."
  sed -i "s/^pi:/$USER:/g" "/etc/passwd"

  # 2. Change the group name in /etc/group
  echo "Renaming user in /etc/group..."
  sed -i "s/\bpi\b/$USER/g" "/etc/group"

  # 3. Rename the home directory from /home/pi to /home/newuser
  echo "Renaming home directory..."
  # replace "pi"" with "$USER" in /etc/passwd
  sed -i "s|pi:|$USER:|g" "/etc/passwd"
  mv "/home/pi" "/home/$USER"

  # 4. Change ownership of the new home directory
  echo "Updating file ownership..."
  chown -R 1000:1000 "/home/$USER"

  # 5. Change the password in /etc/shadow
  echo "Changing user password to $PASSWORD..."
  NEW_HASHED_PASSWORD=$(openssl passwd -6 "$PASSWORD")
  echo "hashed password: $NEW_HASHED_PASSWORD..."
  sed -i "s#^pi:.*#$USER:$NEW_HASHED_PASSWORD:18720:0:99999:7:::#g" "/etc/shadow"

  # 6. don't let raspbian force to change username on first boot
  echo "Disabling first boot user setup wizard..."
  echo "$USER:$NEW_HASHED_PASSWORD" > /boot/firmware/userconf.txt
  chmod 600 /boot/firmware/userconf.txt

  # 7. Add the new user to the sudo group
  echo "Adding $USER to the sudo group..."
  sed -i "/^sudo:/s/pi/$USER/" /etc/group

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
    if ! grep -q "^$group:.*\b$user\b" /etc/group; then
        echo "Adding $user to $group"
        sed -i "/^$group:/s/$/,$user/" /etc/group
    else
        echo "$user is already in $group"
    fi
}

# Add the current user to the 'ovos' group.
echo "Adding $USER to the ovos group..."
# Create the 'ovos' group if it doesn't exist
if ! getent group ovos > /dev/null; then
    groupadd ovos
fi
add_user_to_group $USER ovos

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
TUID=$(awk -F: -v user="$USER" '$1 == user {print $3}' "$PASSWD_FILE")

# Check if UID was successfully retrieved
if [[ -z "$TUID" ]]; then
    echo "Error: Failed to retrieve UID for user '$USER'. Exiting..."
    exit 1
fi

echo "The UID for '$USER' is: $TUID"

# Update package list and install necessary system tools.
# Installs required packages and purges unnecessary ones.
echo "Updating base system..."
apt-get update
# NOTE: zram and mpd need to be installed here otherwise the cmd will hang prompting user about replacing files from overlays
apt-get install -y --no-install-recommends jq git unzip curl build-essential fake-hwclock userconf-pi mosh systemd-zram-generator i2c-tools

echo "Installing audio packages..."
apt-get install -y --no-install-recommends pipewire wireplumber pipewire-alsa alsa-utils portaudio19-dev libpulse-dev libasound2-dev mpd mpv kdeconnect

echo "Installing camera packages..."
apt install -y --no-install-recommends python3-libcamera python3-kms++ libcap-dev

# Copy raspOVOS overlay to the system.
echo "Copying raspOVOS overlay..."
cp -rv /mounted-github-repo/overlays/base/* /

# Ensure the correct permissions for binaries
chmod +x /usr/libexec/*

# NOTE: upmpdcli will only work after the overlays due to trusted keys being added there
echo "Installing extra system packages..."
apt-get update && apt-get install -y --no-install-recommends upmpdcli

# Configure user groups for audio management.
echo "Configuring audio..."
add_user_to_group $USER audio
add_user_to_group $USER pipewire
if getent group rtkit > /dev/null 2>&1; then
    add_user_to_group $USER rtkit
fi

# Modify /etc/fstab for performance optimization.
echo "Tuning /etc/fstab..."
bash /mounted-github-repo/scripts/setup_fstab.sh

# Enable necessary system services.
echo "Enabling system services..."
chmod 644 /etc/systemd/system/kdeconnect.service
ln -s /etc/systemd/system/i2csound.service /etc/systemd/system/multi-user.target.wants/i2csound.service
ln -s /etc/systemd/system/autoconfigure_soundcard.service /etc/systemd/system/multi-user.target.wants/autoconfigure_soundcard.service
ln -s /etc/systemd/system/sshd.service /etc/systemd/system/multi-user.target.wants/sshd.service
ln -s /etc/systemd/system/kdeconnect.service /etc/systemd/system/multi-user.target.wants/kdeconnect.service
ln -s /usr/lib/systemd/system/mpd.service /etc/systemd/system/multi-user.target.wants/mpd.service
ln -s /usr/lib/systemd/system/systemd-zram-setup@.service /etc/systemd/system/multi-user.target.wants/systemd-zram-setup@zram0.service

echo "Ensuring permissions for $USER user..."
chmod 644 /home/$USER/.asoundrc
chown -R $TUID:$TGID /home/$USER

# Enable lingering for the user
echo "Enabling lingering for $USER user ..."
mkdir -p /var/lib/systemd/linger
touch /var/lib/systemd/linger/$USER
# Ensure correct permissions
chown root:root /var/lib/systemd/linger/$USER
chmod 644 /var/lib/systemd/linger/$USER

echo "Cleaning up apt packages..."
apt-get --purge autoremove -y && apt-get clean