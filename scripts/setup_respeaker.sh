#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e


echo "Configuring ReSpeaker drivers..."
# seeed-voicecard

ver="0.3"
marker="0.0.0"

git clone https://github.com/HinTak/seeed-voicecard
cd seeed-voicecard
kernel=$(uname -r)
k_ver=$(echo $kernel | cut -d '.' -f2)
checkout_version="v6.$k_ver"

if git checkout $checkout_version; then
  echo "using version $checkout_version of respeaker drivers"
else
  echo "Could not checkout version $checkout_version"
  echo "Trying default branch"
fi

function install_respeaker {
  local _i

  src=$1
  mod=$2

  if [[ -d /var/lib/dkms/$mod/$ver/$marker ]]; then
    rmdir /var/lib/dkms/$mod/$ver/$marker
  fi

  if [[ -e /usr/src/$mod-$ver || -e /var/lib/dkms/$mod/$ver ]]; then
    dkms remove --force -m $mod -v $ver --all
    rm -rf /usr/src/$mod-$ver
  fi

  mkdir -p /usr/src/$mod-$ver
  cp -a $src/* /usr/src/$mod-$ver/

  dkms add -m $mod -v $ver
  for _i in "${kernels[@]}"; do
    echo "Building for kernel $_i"
    dkms build -k $_i -m $mod -v $ver && {
      dkms install --force -k $_i -m $mod -v $ver
    }
  done

  mkdir -p /var/lib/dkms/$mod/$ver/$marker
}

apt update -y
# Raspbian kernel packages
apt-get -y install raspberrypi-kernel-headers raspberrypi-kernel
# Recent Raspbian has 64-bit kernel on 32-bit userspace
apt-get -y install gcc-aarch64-linux-gnu
# Ubuntu kernel packages
apt-get -y install dkms git i2c-tools libasound2-plugins

kernels=($(ls /boot/vmlinuz-* | sort -V | sed 's|/boot/vmlinuz-||'))

if install_respeaker "./" "seeed-voicecard"; then
  echo "seeed-voicecard drivers are installed"
else
  echo "could not build respeaker drivers"
fi

cd ..

rm -rf seeed-voicecard
