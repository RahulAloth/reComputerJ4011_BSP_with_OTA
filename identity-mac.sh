#!/bin/sh
set -eu
IFACE="${MENDER_ID_IFACE:-enP8p1s0}"
MAC="$(cat /sys/class/net/"$IFACE"/address)"
printf 'mac=%s\n' "$MAC"

