#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e


echo "Configuring noatime and nodiratime..."

# Define the backup file
FSTAB="/etc/fstab"

# Process /etc/fstab
while IFS= read -r line; do
    # Skip comments and empty lines
    if [[ "$line" =~ ^# ]] || [[ -z "$line" ]]; then
        echo "$line"
        continue
    fi

    # Match lines with ext4, xfs, or btrfs filesystems
    if [[ "$line" =~ ^(\S+)\s+(\S+)\s+(ext4|xfs|btrfs)\s+([^#]*)\s+(\d+)\s+(\d+)$ ]]; then
        DEVICE="${BASH_REMATCH[1]}"
        MOUNTPOINT="${BASH_REMATCH[2]}"
        FSTYPE="${BASH_REMATCH[3]}"
        OPTIONS="${BASH_REMATCH[4]}"
        DUMP="${BASH_REMATCH[5]}"
        PASS="${BASH_REMATCH[6]}"

        # Check if "noatime" is already present
        if [[ ! "$OPTIONS" =~ noatime ]]; then
            OPTIONS="$OPTIONS,noatime"
        fi

        # Check if "nodiratime" is already present
        if [[ ! "$OPTIONS" =~ nodiratime ]]; then
            OPTIONS="$OPTIONS,nodiratime"
        fi

        # Print the updated line
        echo -e "$DEVICE\t$MOUNTPOINT\t$FSTYPE\t$OPTIONS\t$DUMP\t$PASS"
    else
        # Print lines that do not match the filesystem types
        echo "$line"
    fi
done < "$FSTAB" > "${FSTAB}.tmp"

# Replace the original fstab with the updated one
mv "${FSTAB}.tmp" "$FSTAB"
echo "Updated /etc/fstab with noatime and nodiratime options."
