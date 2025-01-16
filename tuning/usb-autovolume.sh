#!/bin/bash
# Configuration
readonly DEFAULT_VOLUME=85
readonly STABILIZATION_DELAY=5

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
log_message() {
    echo "$(date) - $1" >> /tmp/autosink.log
}

ACTION=${1:-"unknown"}
ID_MODEL=${2:-"unknown"}

log_message "Udev event: ACTION=$ACTION, ID_MODEL=$ID_MODEL"

if ! command -v pactl &>/dev/null; then
    log_message "pactl not found. Ensure pulseaudio-utils is installed."
    exit 1
fi

# Check if this is an 'add' action for a USB card
if [[ "$ACTION" == "add" ]]; then
    log_message "USB sound card connected: $ID_MODEL"

    # Wait for sinks to stabilize
    sleep "${STABILIZATION_DELAY}"

    # Get the sink name corresponding to the USB card
    USB_SINK=$(pactl list short sinks | grep -i "$ID_MODEL" | awk '{print $2}')
    if [[ -n "$USB_SINK" ]]; then
        # Adjust the volume for the USB sink
        if pactl set-sink-volume "$USB_SINK" "${DEFAULT_VOLUME}%"; then
            log_message "Set volume for USB sink: $USB_SINK to ${DEFAULT_VOLUME}%"
        else
            log_message "Failed to set volume for USB sink: $USB_SINK" "ERROR"
        fi
    else
        log_message "No sink found for USB card: $ID_MODEL"
    fi
fi

readonly SINK_UPDATE_SCRIPT="/usr/libexec/update-audio-sinks.sh"

if [[ -x "${SINK_UPDATE_SCRIPT}" ]]; then
    if ! /bin/bash "${SINK_UPDATE_SCRIPT}"; then
        log_message "Failed to execute sink update script" "ERROR"
        exit 1
    fi
else
    log_message "Sink update script not found or not executable: ${SINK_UPDATE_SCRIPT}" "ERROR"
    exit 1
fi