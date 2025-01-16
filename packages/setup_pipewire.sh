#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

# Install packages
apt install -y --no-install-recommends pipewire pipewire-alsa alsa-utils pulseaudio-utils

SOUND_SERVER="pipewire"

# Function to add user to group in /etc/group
add_user_to_group() {
    local user=$1
    local group=$2
    if ! grep -q "^$group:" /etc/group; then
        echo "Group $group doesn't exist"
        return 1
    fi
    if ! grep -q "^$group:.*\b$user\b" /etc/group; then
        echo "Adding $user to $group"
        sed -i "/^$group:/s/$/,$user/" /etc/group
    else
        echo "$user is already in $group"
    fi
}

# Adding user to audio group
add_user_to_group $USER audio

# Add user to rtkit group if it exists
if getent group rtkit > /dev/null 2>&1; then
    add_user_to_group $USER rtkit
fi

# Add user to pipewire group
add_user_to_group $USER pipewire

# Creating .asoundrc
echo "Creating .asoundrc ..."
echo -e "pcm.!default $SOUND_SERVER\nctl.!default $SOUND_SERVER" > /home/$USER/.asoundrc
chmod 644 /home/$USER/.asoundrc
sudo chown -R 1000:1000 /home/$USER/.asoundrc
