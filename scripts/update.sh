# TODO - flesh out and include in image as /usr/local/bin/ovos-update
#  also see current alias in .bash_aliases

echo "Updating raspovos-audio-setup..."
git clone https://github.com/OpenVoiceOS/raspovos-audio-setup /tmp/raspovos-audio-setup
cp "/tmp/raspovos-audio-setup/autoconfigure_soundcard.service" "/etc/systemd/system/autoconfigure_soundcard.service"
cp "/tmp/raspovos-audio-setup/combine_sinks.service" "/etc/systemd/system/combine_sinks.service"
cp "/tmp/raspovos-audio-setup/ovos-audio-setup" "/usr/local/bin/ovos-audio-setup"
cp "/tmp/raspovos-audio-setup/update-audio-sinks" "/usr/libexec/update-audio-sinks"
cp "/tmp/raspovos-audio-setup/soundcard_autoconfigure" "/usr/libexec/soundcard_autoconfigure"
cp "/tmp/raspovos-audio-setup/usb-autovolume" "/usr/libexec/usb-autovolume"
chmod +x "/usr/local/bin/ovos-audio-setup"
chmod +x "/usr/libexec/update-audio-sinks"
chmod +x "/usr/libexec/soundcard_autoconfigure"
chmod +x "/usr/libexec/usb-autovolume"


# setup ovos-i2csound
echo "updating ovos-i2csound..."
git clone https://github.com/OpenVoiceOS/ovos-i2csound /tmp/ovos-i2csound
cp /tmp/ovos-i2csound/i2c.conf /etc/modules-load.d/i2c.conf
cp /tmp/ovos-i2csound/bcm2835-alsa.conf /etc/modules-load.d/bcm2835-alsa.conf
cp /tmp/ovos-i2csound/i2csound.service /etc/systemd/system/i2csound.service
cp /tmp/ovos-i2csound/ovos-i2csound /usr/libexec/ovos-i2csound
cp /tmp/ovos-i2csound/99-i2c.rules /usr/lib/udev/rules.d/99-i2c.rules
chmod 644 /etc/systemd/system/i2csound.service
chmod +x /usr/libexec/ovos-i2csound
