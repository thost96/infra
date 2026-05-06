#!/bin/bash
set -euxo pipefail

# configure apt for non-interactive mode.
export DEBIAN_FRONTEND=noninteractive

# add support for the pt_PT locale.
sed -i -E 's,.+(de_DE.UTF-8 .+),\1,' /etc/locale.gen
locale-gen
locale -a

# set the keyboard layout.
apt-get install -y console-data
cat >/etc/default/keyboard <<'EOF'
# KEYBOARD CONFIGURATION FILE
# Consult the keyboard(5) manual page.
XKBMODEL="pc105"
XKBLAYOUT="de"
XKBVARIANT=""
XKBOPTIONS=""
KEYMAP="de-utf"
BACKSPACE="guess"
EOF
dpkg-reconfigure keyboard-configuration

# set the timezone.
ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime
dpkg-reconfigure tzdata
