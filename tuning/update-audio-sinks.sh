#!/bin/bash

# Script: update-audio-sinks.sh
# Description: Manages PulseAudio/PipeWire sinks by creating a combined sink
# for multiple audio outputs.
#
# Usage: /usr/libexec/update-audio-sinks.sh

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

# Set the necessary environment variables for PipeWire (or PulseAudio)
export PULSE_RUNTIME_PATH="/run/user/1000/pulse/"
export XDG_RUNTIME_DIR="/run/user/1000/"

log_message "Setting up audio output as combined sinks"

# Log the current sinks before any action
log_message "Sinks before action: $(pactl list short sinks)"

# Get all sinks, excluding 'auto_combined' if it's already loaded
SINKS=$(pactl list short sinks | awk '{print $2}' | grep -v 'auto_combined' | tr '\n' ',' | sed 's/,$//')

# Check if auto_combined is present
if pactl list short sinks | grep -q "auto_combined"; then
    log_message "auto_combined sink exists"
else
    log_message "auto_combined sink missing"
fi

# Count the number of sinks
NUM_SINKS=$(echo "$SINKS" | tr ',' '\n' | wc -l)

log_message "Total sinks: $NUM_SINKS"

# Only create a combined sink if there is more than one sink
if [ "$NUM_SINKS" -gt 1 ]; then
    # Unload any existing combined sink module
    pactl unload-module module-combine-sink 2>/dev/null

    # Set volume of all USB sinks to 100% (or adjust to another level as needed)
    # TODO - figure out how to do this only for the newly connected device
    #for sink in $(echo "$SINKS" | tr ',' '\n'); do
    #    if [[ "$sink" == *"usb"* ]]; then
    #        pactl set-sink-volume "$sink" 85%
    #        log_message "Set volume for USB sink: $sink to 100%"
    #    fi
    #done

    # Create a new combined sink with all available sinks
    pactl load-module module-combine-sink slaves="$SINKS" sink_name=auto_combined

    # Set the combined sink as default
    pactl set-default-sink auto_combined
    log_message "Combined sink created with outputs: $SINKS"
else
    log_message "No sinks found to combine"
fi

# Log the current sinks after action
log_message "Sinks after action: $(pactl list short sinks)"
