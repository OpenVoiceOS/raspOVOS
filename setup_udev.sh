#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

echo "Configuring udev  I/O scheduler rules for MMC and USB..."

# Define the udev rules file path
UDEV_RULES_FILE="/etc/udev/rules.d/60-mmc-usb-scheduler.rules"

# Check if the rules file exists and create if necessary
if [ ! -f "$UDEV_RULES_FILE" ]; then
    echo "Creating udev rules file at $UDEV_RULES_FILE"
    touch "$UDEV_RULES_FILE"
    chown root:root "$UDEV_RULES_FILE"
    chmod 644 "$UDEV_RULES_FILE"
fi

# Add I/O scheduler rules for MMC and USB
echo 'ACTION=="add|change", KERNEL=="mmc*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"' >> "$UDEV_RULES_FILE"
echo 'ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{removable}=="1", ATTR{queue/scheduler}="none"' >> "$UDEV_RULES_FILE"

echo "I/O scheduler rules applied for MMC and USB devices."


