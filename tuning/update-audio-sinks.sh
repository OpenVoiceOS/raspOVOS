#!/bin/bash

# Script: update-audio-sinks.sh
# Description: Manages PulseAudio/PipeWire sinks by creating a combined sink
# for multiple audio outputs.
#
# Usage: /usr/libexec/update-audio-sinks.sh

# Set the necessary environment variables for PipeWire (or PulseAudio)
# needed if running as root
export PULSE_RUNTIME_PATH="/run/user/1000/pulse/"
export XDG_RUNTIME_DIR="/run/user/1000/"

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
# Args:
#   $1: Message to log
log_message() {
    echo "$(date) - $1" >> /tmp/autosink.log
}

if ! command -v pactl &>/dev/null; then
    log_message "pactl not found. Ensure pulseaudio-utils is installed."
    exit 1
fi


log_message "Setting up audio output as combined sinks"

# Check if auto_null is present, might happen early on boot
if pactl list short sinks | grep -q "auto_null"; then
    log_message "auto_null sink exists, still booting? Sleeping for 3 seconds..."
    sleep 3
fi

# Log the current sinks before any action
log_message "Sinks before action:\n $(pactl list short sinks)"

# Get all sinks, excluding 'auto_combined' if it's already loaded
SINKS=$(pactl list short sinks | awk '{print $2}' | grep -v 'auto_combined'  | grep -v 'auto_null' | tr '\n' ',' | sed 's/,$//')
NUM_SINKS=$(echo "$SINKS" | tr ',' '\n' | wc -l)

RETRIES=5
while [ "$NUM_SINKS" -eq 0 ] && [ "$RETRIES" -gt 0 ]; do
    log_message "Retrying to find sinks..."
    sleep 1
    RETRIES=$((RETRIES - 1))
    SINKS=$(pactl list short sinks | awk '{print $2}' | grep -v 'auto_combined' | grep -v 'auto_null' | tr '\n' ',' | sed 's/,$//')
    NUM_SINKS=$(echo "$SINKS" | tr ',' '\n' | wc -l)
done

# Check if auto_combined is present
if pactl list short sinks | grep -q "auto_combined"; then
    log_message "auto_combined sink exists"
else
    log_message "auto_combined sink missing"
fi

log_message "Total sinks: $NUM_SINKS"

# Only create a combined sink if there is more than one sink
if [ "$NUM_SINKS" -gt 1 ]; then
    # Unload any existing combined sink module
    pactl unload-module module-combine-sink 2>/dev/null

    # Create a new combined sink with all available sinks
    if ! MODULE_ID=$(pactl load-module module-combine-sink slaves="$SINKS" sink_name=auto_combined); then
        log_message "Failed to create combined sink"
        exit 1
    fi

    # Verify the sink exists before setting as default
    if pactl list short sinks | grep -q "auto_combined"; then
        pactl set-default-sink auto_combined
        log_message "Combined sink created with outputs: $SINKS (module ID: $MODULE_ID)"
    else
        log_message "Combined sink creation failed"
        exit 1
    fi
else
    log_message "No sinks found to combine"
fi

# Log the current sinks after action
log_message "Sinks after action:\n $(pactl list short sinks)"
