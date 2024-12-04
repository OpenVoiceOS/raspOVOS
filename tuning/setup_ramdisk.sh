#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e


# Create a ramdisk
echo "tmpfs /ramdisk tmpfs rw,nodev,nosuid,size=20M 0 0" >> "/etc/fstab"
mkdir -p /home/$USER/.local/state/mycroft/
ln -s /ramdisk/mycroft/audio.log /home/$USER/.local/state/mycroft/
ln -s /ramdisk/mycroft/bus.log /home/$USER/.local/state/mycroft/
ln -s /ramdisk/mycroft/gui.log /home/$USER/.local/state/mycroft/
ln -s /ramdisk/mycroft/ovos.log /home/$USER/.local/state/mycroft/
ln -s /ramdisk/mycroft/ovos_shell.log /home/$USER/.local/state/mycroft/
ln -s /ramdisk/mycroft/phal_admin.log /home/$USER/.local/state/mycroft/
ln -s /ramdisk/mycroft/phal.log /home/$USER/.local/state/mycroft/
ln -s /ramdisk/mycroft/skills.log /home/$USER/.local/state/mycroft/
ln -s /ramdisk/mycroft/voice.log /home/$USER/.local/state/mycroft/


# Set permissions for /ramdisk/mycroft
chmod 2775 /ramdisk/mycroft
