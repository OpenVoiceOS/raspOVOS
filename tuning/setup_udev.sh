#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

echo "Configuring udev  I/O scheduler rules for MMC and USB..."

# Define the udev rules file path
UDEV_RULES_FILE="/etc/udev/rules.d/60-mmc-usb-scheduler.rules"
UDEV_AUDIO_RULES_FILE="/etc/udev/rules.d/91-pulseadio-GeneralPlus.rules"

# Specific HAT rules
UDEV_RESPEAKER_FILE="/etc/udev/rules.d/91-seeedvoicecard.rules"

# Check if the rules file exists and create if necessary
if [ ! -f "$UDEV_RULES_FILE" ]; then
    echo "Creating udev rules file at $UDEV_RULES_FILE"
    touch "$UDEV_RULES_FILE"
    chown root:root "$UDEV_RULES_FILE"
    chmod 644 "$UDEV_RULES_FILE"
fi

# Check if the rules file exists and create if necessary
if [ ! -f "$UDEV_AUDIO_RULES_FILE" ]; then
    echo "Creating udev rules file at $UDEV_AUDIO_RULES_FILE"
    touch "$UDEV_AUDIO_RULES_FILE"
    chown root:root "$UDEV_AUDIO_RULES_FILE"
    chmod 644 "$UDEV_AUDIO_RULES_FILE"
fi

# Check if the rules file exists and create if necessary
if [ ! -f "$UDEV_RESPEAKER_FILE" ]; then
    echo "Creating udev rules file at $UDEV_RESPEAKER_FILE"
    touch "$UDEV_RESPEAKER_FILE"
    chown root:root "$UDEV_RESPEAKER_FILE"
    chmod 644 "$UDEV_RESPEAKER_FILE"
fi

# Add I/O scheduler rules for MMC and USB
echo 'ACTION=="add|change", KERNEL=="mmc*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"' >> "$UDEV_RULES_FILE"
echo 'ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{removable}=="1", ATTR{queue/scheduler}="none"' >> "$UDEV_RULES_FILE"

echo "I/O scheduler rules applied for MMC and USB devices."

# Add a combined audio output
echo 'ACTION=="change", SUBSYSTEM=="sound", KERNEL=="card*", \
ATTRS{subsystem_vendor}=="0x1b3f", ATTRS{subsystem_device}=="0x2008", ENV{ACP_PROFILE_SET}="GeneralPlus.conf"' >> "$UDEV_AUDIO_RULES_FILE"

echo "Combined audio output rules applied"

# Respeaker rules
cat << EOF >> "$UDEV_RESPEAKER_FILE"
SUBSYSTEM!="sound", GOTO="seeedvoicecard_end"
ACTION!="change", GOTO="seeedvoicecard_end"
KERNEL!="card*", GOTO="seeedvoicecard_end"

# ALSA profile sets
ATTR{id}=="seeed4micvoicec",ENV{ACP_PROFILE_SET}="seeed-voicecard-4mic.conf"
ATTR{id}=="seeed8micvoicec",ENV{ACP_PROFILE_SET}="seeed-voicecard-8mic.conf"

LABEL="seeedvoicecard_end"
EOF

# GeneralPlus (audio udev file)
PIPEWIRE_PROFILE_DIR="/usr/share/alsa-card-profile/mixer/profile-sets"

# Check if the configuration file exists and create if necessary
if [ ! -d "$PIPEWIRE_PROFILE_DIR" ]; then
    echo "Creating directory for pipewire profiles $PIPEWIRE_PROFILE_DIR"
    mkdir -p "$PIPEWIRE_PROFILE_DIR"
    chown root:root "$PIPEWIRE_PROFILE_DIR"
    chmod 755 "$PIPEWIRE_PROFILE_DIR"
fi

cp -v /mounted-github-repo/tuning/GeneralPlus.conf $PIPEWIRE_PROFILE_DIR/GeneralPlus.conf
chmod 644 "$PIPEWIRE_PROFILE_DIR/GeneralPlus.conf"

# Respeaker profile files
cp -v /mounted-github-repo/tuning/seeed-voicecard-4mic.conf $PIPEWIRE_PROFILE_DIR/seeed-voicecard-4mic.conf
chmod 644 "$PIPEWIRE_PROFILE_DIR/seeed-voicecard-4mic.conf"

cp -v /mounted-github-repo/tuning/seeed-voicecard-8mic.conf $PIPEWIRE_PROFILE_DIR/seeed-voicecard-8mic.conf
chmod 644 "$PIPEWIRE_PROFILE_DIR/seeed-voicecard-8mic.conf"
