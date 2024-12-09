alias ologs="tail -f ~/.local/state/mycroft/!(bus.log)"

# OVOS Status: List OVOS-related systemd services
alias ovos-status="systemctl --user list-units | grep ovos"

alias ovos-restart="systemctl --user restart ovos"

# OVOS Freeze: Save installed OVOS and skill-related packages to requirements.txt
alias ovos-freeze="uv pip list --format=freeze | grep -E 'ovos-|skill-' > requirements.txt"

# OVOS Update: Update all OVOS and skill-related packages
alias ovos-update="uv pip install -c https://github.com/OpenVoiceOS/ovos-releases/raw/refs/heads/main/constraints-testing.txt -U --pre \$(uv pip list --format=freeze | grep -E 'ovos-|skill-' | cut -d '=' -f 1)"

# To attempt to recover a system
alias ovos-force-reinstall="uv pip install --pre ovos-docs-viewer ovos-utils[extras] ovos-dinkum-listener[extras,linux,onnx] tflite_runtime ovos-phal[extras,linux] ovos-audio[extras] ovos-gui ovos-core[lgpl,plugins,skills-audio,skills-essential,skills-internet,skills-media,skills-extra] -c https://github.com/OpenVoiceOS/ovos-releases/raw/refs/heads/main/constraints-stable.txt --force-reinstall"

# OVOS Outdated: List outdated OVOS and skill-related packages
alias ovos-outdated="uv pip list --outdated | grep -E 'ovos-|skill-'"

# OVOS Pip: Run pip commands with a constraints file
alias ovos-install="uv pip install -c https://github.com/OpenVoiceOS/ovos-releases/raw/refs/heads/main/constraints-testing.txt"

# OVOS quick docs:
alias ovos-logo="/bin/bash ~/.logo.sh"
alias ovos-manual="~/.venvs/ovos/bin/ovos-docs-viewer technical"
alias ovos-skills-info="~/.venvs/ovos/bin/ovos-docs-viewer skills"
alias ovos-server-status="~/.venvs/ovos/bin/ovos-docs-viewer live-status"
alias ovos-help="/bin/bash ~/.cli_login.sh"

# list installed plugins
alias ls-skills="~/.venvs/ovos/bin/python -c \"from ovos_plugin_manager.skills import get_installed_skill_ids; from ovos_utils.log import LOG; LOG.set_level('ERROR'); from pprint import pprint; pprint(get_installed_skill_ids())\""
alias ls-stt="~/.venvs/ovos/bin/python -c \"from ovos_plugin_manager.stt import find_stt_plugins; from ovos_utils.log import LOG; LOG.set_level('ERROR'); from pprint import pprint; pprint(find_stt_plugins())\""
alias ls-tts="~/.venvs/ovos/bin/python -c \"from ovos_plugin_manager.tts import find_tts_plugins; from ovos_utils.log import LOG; LOG.set_level('ERROR'); from pprint import pprint; pprint(find_tts_plugins())\""
alias ls-tx="~/.venvs/ovos/bin/python -c \"from ovos_plugin_manager.language import find_tx_plugins; from ovos_utils.log import LOG; LOG.set_level('ERROR'); from pprint import pprint; pprint(find_tx_plugins())\""
alias ls-ww="~/.venvs/ovos/bin/python -c \"from ovos_plugin_manager.wakewords import find_wake_word_plugins; from ovos_utils.log import LOG; LOG.set_level('ERROR'); from pprint import pprint; pprint(find_wake_word_plugins())\""

# helper to "reset OVOS brain"
alias ovos-rm-skills="uv pip list | grep skill | awk '{print $1}' | xargs uv pip uninstall"