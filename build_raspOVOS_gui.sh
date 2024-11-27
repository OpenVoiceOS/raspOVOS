#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

# TODO - reuse previous image instead, failing for some reason
bash /mounted-github-repo/build_raspOVOS.sh

# Activate the virtual environment
source /home/$USER/.venvs/ovos/bin/activate

echo "Creating system level mycroft.conf..."
cp -v /mounted-github-repo/mycroft_gui.conf /etc/mycroft/mycroft.conf

# TODO install ovos-shell

echo "Setting up systemd..."
mkdir -p /home/$USER/.config/systemd/user/
cp -v /mounted-github-repo/ovos-shell.service /home/$USER/.config/systemd/user/
chmod 644 /home/$USER/.config/systemd/user/*.service

# Enable services manually by creating symbolic links
mkdir -p /home/$USER/.config/systemd/user/default.target.wants/
ln -s /home/$USER/.config/systemd/user/ovos-shell.service /home/$USER/.config/systemd/user/default.target.wants/ovos-shell.service


echo "Ensuring permissions for $USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$USER

echo "Cleaning up apt packages..."
apt-get --purge autoremove -y && apt-get clean