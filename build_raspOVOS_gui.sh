#!/bin/bash
# Exit on error
# If something goes wrong just stop.
# it allows the user to see issues at once rather than having
# scroll back and figure out what went wrong.
set -e

# Activate the virtual environment
source /home/$USER/.venvs/ovos/bin/activate

# Function to add user to group in /etc/group
add_user_to_group() {
    local user=$1
    local group=$2
    if ! grep -q "^$group:" /etc/group; then
        echo "Group $group doesn't exist"
        return 1
    fi
    if ! grep -q "^$group:.*\b$user\b" /etc/group; then
        echo "Adding $user to $group"
        sed -i "/^$group:/s/$/,$user/" /etc/group
    else
        echo "$user is already in $group"
    fi
}
echo "Customizing boot/firmware/config.txt..."
cp -v /mounted-github-repo/patches/boot_config_gui.txt /boot/firmware/config.txt

echo "Adding user to video and render groups..."
# Adding user to video group
add_user_to_group $USER video
# Adding user to render group
add_user_to_group $USER render

echo "Installing QT5 dependencies..."
apt-get install -y jq cmake extra-cmake-modules kio kio-extras plasma-framework libqt5websockets5-dev libqt5webview5-dev qtdeclarative5-dev libqt5multimediaquick5 libqt5multimedia5-plugins libqt5webengine5 libkf5dbusaddons-dev libkf5iconthemes-dev kirigami2-dev qtmultimedia5-dev libkf5plasma-dev libkf5kio-dev qml-module-qtwebengine libqt5virtualkeyboard5 qml-module-qtmultimedia libinput-dev evemu-tools breeze-icon-theme libqt5svg5-dev qt5-qmake qtbase5-dev qtbase5-private-dev libxcb-xfixes0-dev

echo "Installing GUI plugins and skills..."
uv pip install --no-progress ovos-core[skills-gui] ovos-gui[extras] -c $CONSTRAINTS

echo "Creating system level mycroft.conf..."
mkdir -p /etc/mycroft

CONFIG_ARGS=""
# Loop through the MYCROFT_CONFIG_FILES variable and append each file to the jq command
IFS=',' read -r -a config_files <<< "$MYCROFT_CONFIG_FILES"
for file in "${config_files[@]}"; do
  CONFIG_ARGS="$CONFIG_ARGS /mounted-github-repo/$file"
done
# Execute the jq command and merge the files into mycroft.conf
jq -s 'reduce .[] as $item ({}; . * $item)' $CONFIG_ARGS > /etc/mycroft/mycroft.conf


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

/usr/bin/kbuildsycoca5

echo "Setting up systemd..."
mkdir -p /home/$USER/.config/systemd/user/
cp -v /mounted-github-repo/services/ovos-shell.service /home/$USER/.config/systemd/user/
chmod 644 /home/$USER/.config/systemd/user/ovos-shell.service

# Enable services manually by creating symbolic links
mkdir -p /home/$USER/.config/systemd/user/default.target.wants/
ln -s /home/$USER/.config/systemd/user/ovos-shell.service /home/$USER/.config/systemd/user/default.target.wants/ovos-shell.service


echo "Ensuring permissions for $USER user..."
# Replace 1000:1000 with the correct UID:GID if needed
chown -R 1000:1000 /home/$USER

echo "Cleaning up apt packages..."
apt-get --purge autoremove -y && apt-get clean