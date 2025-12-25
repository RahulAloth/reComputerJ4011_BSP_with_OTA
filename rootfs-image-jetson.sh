#!/bin/sh

set -ue

STATE="$1"
FILES="$2"

ota_payload_package="$FILES"/files/ota_payload_package.tar.gz
nvidia_tools="$FILES"/files/ota_tools_aarch64.tbz2

# Nvidia uses the concept of "slots", they will
# be always 0 and 1 values for A and B partitions

MENDER_ROOTFS_PART_A_NUMBER="0"
MENDER_ROOTFS_PART_B_NUMBER="1"

# Some useful information for integrity check
mkdir -p "/data/fs_update/"
mender_boot_part="/data/fs_update/mender_boot_part"
active_num="$(nvbootctrl get-current-slot)"

if test $active_num -eq $MENDER_ROOTFS_PART_A_NUMBER; then
    passive_num=$MENDER_ROOTFS_PART_B_NUMBER
else
    passive_num=$MENDER_ROOTFS_PART_A_NUMBER
fi

case "$STATE" in
      Download)
        if [ "$(nvbootctrl get-number-slots)" != "2" ]; then
            echo "Your device need to be configured to use A/B partitioning"
            exit 1
        fi
        ;;

    ArtifactInstall)
        # Let's record what slot we expect to boot next time
        echo $passive_num > $mender_boot_part
        # Let's enable Nvidia's scripts
        mkdir -p "$HOME"/workdir
        export WORKDIR="$HOME"/workdir
        tar -jxvf $nvidia_tools -C $WORKDIR
        # UDA partition as temp location disabled initially
        UDA=""
        # If you have a big enough UDA partition or a small rootfs
        # partition size, uncomment the following line  
        #UDA="data/"
        # Let's move the payload
        mkdir -p "/${UDA}ota/"
        mv $ota_payload_package "/${UDA}ota/"
        mkdir -p "/${UDA}ota_work"
        if [ ! -z "$UDA" ]
        then
            ln -sfn "/${UDA}ota_work" "/ota_work"
        fi
        # Let's run the upgrade process
        cd ${WORKDIR}/Linux_for_Tegra/tools/ota_tools/version_upgrade
        ./nv_ota_start.sh /dev/mmcblk0 "/${UDA}ota/ota_payload_package.tar.gz"
        # nv_ota_start.sh set the unused slot to active for next reboot
        >&2 echo "Next boot will load Slot $passive_num" 
        #cleaning up the disk
        if [ ! -z "$UDA" ]; then
            rm -rf "/${UDA}ota_work"
            rm -rf "/${UDA}ota/"
        fi   
        ;;

    PerformsFullUpdate)
        echo "Yes"
        ;;

    NeedsArtifactReboot)
        echo "Automatic"
        ;;

    SupportsRollback)
        echo "Yes"
        ;;

    ArtifactVerifyReboot)
        # We use stderr for logging as Mender protocol uses stdout for exchanging messages with the server.
        >&2 echo "ArtifactVerifyReboot: The active partition is $active_num while the last passive was $(cat $mender_boot_part)"
        if test "$(cat $mender_boot_part)" != "$active_num"; then
            exit 1
        fi
        # Recommend calling sync at the end here as well
        sync
        ;;

    ArtifactVerifyRollbackReboot)
        >&2 echo "ArtifactVerifyRollbackReboot: The active partition is $active_num while the last passive was $(cat $mender_boot_part)"
        if test "$(cat $mender_boot_part)" = "$active_num"; then
            exit 1
        fi
        # Recommend calling sync at the end here as well
        sync
        ;;

    ArtifactCommit)
        >&2 echo "ArtifactCommit: The active partition is $active_num while the last passive was $(cat $mender_boot_part)"
        if test "$(cat $mender_boot_part)" = "$active_num"; then
            nvbootctrl mark-boot-successful
        else
            # If we get here, an upgrade in standalone mode failed to  
            # boot and the user is trying to commit from the old OS.
            # This communicates to the user that the upgrade failed.
            echo "Upgrade failed and was reverted: refusing to commit!"
            exit 1
        fi
        ;;

    ArtifactRollback)
        >&2 echo "ArtifactRollback: The active partition is $active_num while the last passive was $(cat $mender_boot_part)"
        if test "$(cat $mender_boot_part)" = "$active_num"; then
            nvbootctrl set-active-boot-slot $passive_num
        fi
        sync
        ;;

esac
exit 0
