#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

# Activate the virtual environment
source /home/$USER/.venvs/ovos/bin/activate

echo "Installing GUI plugins and skills..."
pip3 install ovos-core[skills-gui] ovos-gui[extras] -c /etc/mycroft/constraints.txt

echo "Creating system level mycroft.conf..."
cp -v /mounted-github-repo/mycroft_gui.conf /etc/mycroft/mycroft.conf

sudo apt-get install -y cmake extra-cmake-modules kio kio-extras plasma-framework libqt5websockets5-dev libqt5webview5-dev qtdeclarative5-dev libqt5multimediaquick5 libqt5multimedia5-plugins libqt5webengine5 libkf5dbusaddons-dev libkf5iconthemes-dev kirigami2-dev qtmultimedia5-dev libkf5plasma-dev libkf5kio-dev qml-module-qtwebengine libqt5virtualkeyboard5 qml-module-qtmultimedia libinput-dev evemu-tools breeze-icon-theme libqt5svg5-dev qt5-qmake qtbase5-dev qtbase5-private-dev libxcb-xfixes0-dev

# Mycroft-gui-qt5
cd /home/$USER
git clone https://github.com/OpenVoiceOS/mycroft-gui-qt5
cd mycroft-gui-qt5
echo "Building OVOS QT5 GUI"
mkdir build && cd build
cmake .. -DBUILD_WITH_QT6=OFF -DQT_MAJOR_VERSION=5 -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DKDE_INSTALL_LIBDIR=lib -DKDE_INSTALL_USE_QT_SYS_PATHS=ON
make
make install
cd /home/$USER
rm -rf mycroft-gui-qt5

git clone https://github.com/kbroulik/lottie-qml
cd lottie-qml
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release   -DKDE_INSTALL_LIBDIR=lib -DKDE_INSTALL_USE_QT_SYS_PATHS=ON
make
make install
cd /home/$USER
rm -rf lottie-qml

# ovos-shell
git clone https://github.com/OpenVoiceOS/ovos-shell
cd ovos-shell
echo "Building OVOS Shell"
if [[ ! -d build-testing ]] ; then
    mkdir build-testing
fi
cd build-testing
cmake .. -DBUILD_WITH_QT6=OFF -DQT_MAJOR_VERSION=5 -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DKDE_INSTALL_LIBDIR=lib -DKDE_INSTALL_USE_QT_SYS_PATHS=ON
make
make install
cd /home/$USER
rm -rf ovos-shell

echo "Setting up systemd..."
mkdir -p /home/$USER/.config/systemd/user/
cp -v /mounted-github-repo/ovos-shell.service /home/$USER/.config/systemd/user/
chmod 644 /home/$USER/.config/systemd/user/*.service

# Enable services manually by creating symbolic links
mkdir -p /home/$USER/.config/systemd/user/default.target.wants/
ln -s /home/$USER/.config/systemd/user/ovos-shell.service /home/$USER/.config/systemd/user/default.target.wants/ovos-shell.service


echo "Ensuring permissions for $USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$USER

echo "Cleaning up apt packages..."
apt-get --purge autoremove -y && apt-get clean