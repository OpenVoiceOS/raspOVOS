alias ologs="tail -f ~/.local/state/mycroft/!(bus.log)"

# OVOS Status: List OVOS-related systemd services
alias ovos-status="systemctl --user list-units | grep ovos"

alias ovos-restart="systemctl --user restart ovos"

# OVOS Freeze: Save installed OVOS and skill-related packages to requirements.txt
alias ovos-freeze="uv pip list --format=freeze | grep -E 'ovos-|skill-' > requirements.txt"

# To attempt to recover a system
alias ovos-force-reinstall="uv pip install --pre ovos-docs-viewer ovos-utils[extras] ovos-dinkum-listener[extras,linux,onnx] tflite_runtime ovos-phal[extras,linux] ovos-audio[extras] ovos-gui ovos-core[lgpl,plugins,skills-audio,skills-essential,skills-internet,skills-media,skills-extra] -c https://github.com/OpenVoiceOS/ovos-releases/raw/refs/heads/main/constraints-stable.txt --force-reinstall"

# OVOS Outdated: List outdated OVOS and skill-related packages
alias ovos-outdated="uv pip list --outdated | grep -E 'ovos-|skill-'"

# OVOS Pip: Run pip commands with a constraints file
alias ovos-install="uv pip install -c https://github.com/OpenVoiceOS/ovos-releases/raw/refs/heads/main/constraints-testing.txt"

# OVOS quick docs:
alias ovos-manual="~/.venvs/ovos/bin/ovos-docs-viewer technical"
alias ovos-skills-info="~/.venvs/ovos/bin/ovos-docs-viewer skills"
alias ovos-server-status="~/.venvs/ovos/bin/ovos-docs-viewer live-status"
