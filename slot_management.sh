#!/usr/bin/env bash
set -euo pipefail

echo "=== Jetson OTA Test: Slot Management ==="

# Step 1: Check current slot status
echo "Current slot info:"
sudo nvbootctrl -t rootfs dump-slots-info

# Step 2: Reset slot A (slot 0) to bootable
echo "Resetting slot A to bootable..."
sudo nvbootctrl -t rootfs set-retry-count 0 7
sudo nvbootctrl -t rootfs set-slot-status 0 normal

# Step 3: Set slot A as active for next boot
echo "Setting slot A as active boot slot..."
sudo nvbootctrl -t rootfs set-active-boot-slot 0

# Step 4: Confirm changes
echo "Updated slot info:"
sudo nvbootctrl -t rootfs dump-slots-info

# Step 5: Reboot to test slot A
echo "Rebooting to test slot A..."
sudo reboot
