#!/bin/bash
NAME="$(tailscale status --json | jq '.Self.DNSName | .[:-1]' -r)"
tailscale cert --cert-file /etc/proxmox-backup/proxy.pem --key-file /etc/proxmox-backup/proxy.key "${NAME}" && \
chown backup:backup /etc/proxmox-backup/proxy.pem /etc/proxmox-backup/proxy.key && \
systemctl reload proxmox-backup-proxy
