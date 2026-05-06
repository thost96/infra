#!/bin/bash
set -euxo pipefail

# configure apt for non-interactive mode.
export DEBIAN_FRONTEND=noninteractive

# reset proxmox default ip back to dhcp
cat >/etc/network/interfaces <<'EOF'
auto lo
iface lo inet loopback

auto nic0
iface nic0 inet dhcp
EOF
