#!/bin/bash
set -euxo pipefail

# configure apt for non-interactive mode.
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install isc-dhcp-client -y

# reset proxmox default ip back to dhcp
cat >/etc/network/interfaces <<'EOF'
auto lo
iface lo inet loopback

auto enp6s18
iface enp6s18 inet manual

auto vmbr0
iface vmbr0 inet dhcp
  bridge-ports enp6s18
  bridge-stp off
  bridge-fd 0
EOF

cat >/etc/dhcp/dhclient-exit-hooks.d/update-etc-hosts <<'EOF'
if ([ $reason = "BOUND" ] || [ $reason = "RENEW" ])
then
  sed -i "s/^.*\spve.local\s.*$/${new_ip_address} pve.local pve/" /etc/hosts
fi
EOF