#!/bin/bash

# Set error handling
set -euo pipefail

# Function to handle errors
error_handler() {
    local line_no=$1
    local error_code=$2
    log_message "Error (code: ${error_code}) occurred on line ${line_no}"
    exit ${error_code}
}

trap 'error_handler ${LINENO} $?' ERR

# Log function to write to a log file
log_message() {
    echo "$(date) - $1" >> /tmp/autosink.log
}

ACTION=${1:-"unknown"}
ID_MODEL=${2:-"unknown"}

log_message "Udev event: ACTION=$ACTION, ID_MODEL=$ID_MODEL"

# Check if this is an 'add' action for a USB card
if [[ "$ACTION" == "add" ]]; then
    log_message "USB sound card connected: $ID_MODEL"

    # Wait for sinks to stabilize
    sleep 5

    # Get the sink name corresponding to the USB card
    USB_SINK=$(pactl list short sinks | grep -i "$ID_MODEL" | awk '{print $2}')
    if [[ -n "$USB_SINK" ]]; then
        # Adjust the volume for the USB sink
        pactl set-sink-volume "$USB_SINK" 85%
        log_message "Set volume for USB sink: $USB_SINK to 85%"
    else
        log_message "No sink found for USB card: $ID_MODEL"
    fi
fi

/bin/bash /usr/libexec/update-audio-sinks.sh