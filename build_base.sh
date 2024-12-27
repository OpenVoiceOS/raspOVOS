#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e


# if $USER is different from "pi"  (the default) rename "pi" to "$USER"
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
  chown -R 1000:1000 "/home/$USER"    # Replace 1000:1000 with the correct UID:GID if needed

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

echo "Adding $USER to the ovos group..."
# Create the 'ovos' group if it doesn't exist
if ! getent group ovos > /dev/null; then
    groupadd ovos
fi
add_user_to_group $USER ovos

echo "Patching userconf to ensure 'ovos' group always exists..."
cp -v /mounted-github-repo/patches/userconf /usr/lib/userconf-pi/userconf


echo "Changing system hostname to $HOSTNAME..."
# Update /etc/hostname
echo "$HOSTNAME" > /etc/hostname
# Update /etc/hosts to reflect the new hostname
sed -i "s/127.0.1.1.*$/127.0.1.1\t$HOSTNAME/" /etc/hosts

echo "Enabling ssh..."
ln -s /etc/systemd/system/sshd.service /etc/systemd/system/multi-user.target.wants/
touch /boot/firmware/ssh

echo "Enabling autologin..."
# patch first bootscript to ensure autologin is enabled, otherwise OVOS doesnt launch!
cp -v /mounted-github-repo/patches/firstboot /usr/lib/raspberrypi-sys-mods/firstboot
mkdir -p /var/lib/userconf-pi/
touch /var/lib/userconf-pi/autologin

# Update package list and install necessary tools
echo "Updating base system..."
apt-get update
apt-get install -y --no-install-recommends jq git unzip curl build-essential fake-hwclock userconf-pi swig python3-dev python3-pip fbi libasound2-dev
# what else can be removed to make the system even lighter?
apt purge -y cups ppp

echo "Setting up libcamera..."
apt install -y python3-libcamera python3-kms++ libcap-dev

echo "Setting rfkill default value..."
cp -v /mounted-github-repo/tuning/rfkill_default.conf /etc/modprobe.d/rfkill_default.conf

echo "Installing uv and sdnotify..."
pip install sdnotify uv --break-system-packages

echo "Installing Pipewire..."
bash /mounted-github-repo/packages/setup_pipewire.sh

echo "Installing KDEConnect..."
bash /mounted-github-repo/packages/setup_kdeconnect.sh

echo "Installing Librespot..."
bash /mounted-github-repo/packages/setup_spotify.sh

#echo "Installing Balena Wifi-connect..."
#bash /mounted-github-repo/packages/setup_balena_wifi.sh

echo "Tuning base system..."
cp -v /mounted-github-repo/patches/boot_config.txt /boot/firmware/config.txt
#bash /mounted-github-repo/tuning/setup_ramdisk.sh
bash /mounted-github-repo/tuning/setup_zram.sh
#bash /mounted-github-repo/tuning/setup_cpugovernor.sh
bash /mounted-github-repo/tuning/setup_wlan0power.sh
bash /mounted-github-repo/tuning/setup_fstab.sh
bash /mounted-github-repo/tuning/setup_sysctl.sh
bash /mounted-github-repo/tuning/setup_udev.sh
bash /mounted-github-repo/tuning/setup_nmanager.sh
# make boot faster by printing less stuff and skipping file system checks
grep -q "quiet fastboot" /boot/firmware/cmdline.txt || sed -i 's/$/ quiet fastboot/' /boot/firmware/cmdline.txt

echo "Ensuring permissions for $USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$USER

# Enable lingering for the user
echo "Enabling lingering for $USER user ..."
# Enable lingering by creating the directory
mkdir -p /var/lib/systemd/linger

# Create an empty file with the user's name
touch /var/lib/systemd/linger/$USER

# Ensure correct permissions
chown root:root /var/lib/systemd/linger/$USER
chmod 644 /var/lib/systemd/linger/$USER

echo "Cleaning up apt packages..."
apt-get --purge autoremove -y && apt-get clean