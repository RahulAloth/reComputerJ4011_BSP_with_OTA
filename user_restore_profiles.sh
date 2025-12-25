#!/bin/bash
# ArtifactInstall_Leave_00-restore.sh — Post-install restore for Jetson OTA
# Author: Rahul A R, Version: 1. 0

set -euo pipefail

LOG="/var/log/mender-restore.log"
log() { echo "$(date '+%F %T') — $*" | tee -a "$LOG"; }

# === Restore NetworkManager ===
log "Restoring NetworkManager connections"
if compgen -G "/data/network/*.nmconnection" > /dev/null; then
    cp /data/nm_profile/*.nmconnection /etc/NetworkManager/system-connections/
    chmod 600 /etc/NetworkManager/system-connections/*.nmconnection
    nmcli connection reload
    log "NetworkManager connections restored"
else
    log "No .nmconnection files found in /data/network"
fi

# === Restore SSH Keys ===
log "Restoring SSH keys"
mkdir -p ~/.ssh
if compgen -G "/data/.ssh/*" > /dev/null; then
    cp -r /data/.ssh/* ~/.ssh/
    chmod 600 ~/.ssh/*
    chmod 700 ~/.ssh
    log "SSH keys restored"
else
    log "No SSH keys found in /data/.ssh"
fi

# === Restore SocketCAN Service ===
log "Restoring SocketCAN service"
if [[ -f /data/can/socketcan.service ]]; then
    cp /data/can/socketcan.service /etc/systemd/system/
    systemctl enable socketcan.service
    log "SocketCAN service enabled"
else
    log "socketcan.service not found in /data/can"
fi

log 