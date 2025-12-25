
# Taking advantage of the UDA partition

We uses the UDA partition to store information that will be shared between root filesystems A and B. It will help us to do data persistence.



      sudo mkfs.ext4 /dev/nvme0n1p15
      sudo mkdir -p /data
      sudo su -c "echo '/dev/nvme0n1p15 /data ext4 defaults 0 0' >> /etc/fstab"
      sudo mount -a

Some Mender files have to live in the /data partition. Move them as follows:

      sudo mv /var/lib/mender /data
      sudo ln -s /data/mender /var/lib/mender

If we want to restore our scripts in future, do the following:

### Copy NetworkManager

      mkdir -p /data/nm_profile
      sudo cp /etc/NetworkManager/system-connections/*.nmconnection /data/nm_profile/

### Restore SSH Keys

      mkdir -p /data/.ssh
      sudo cp -r ~/.ssh/* /data/.ssh/



### Restore SocketCAN Service

      mkdir -p /data/can
      sudo cp /etc/systemd/system/socketcan.service /data/can
      


## Create Snapshot.
Follow the steps below:

Step1: In the Jetson, do:

      sudo dd if=/dev//dev/nvme0n1p15 of=<mount ponint>/golden_b.img.raw

 Step 2:  Copy the golden images into the TARGET_BSP directory on the host machine by running the following commands:

 
      sudo cp golden_b.img.raw ${TARGET_BSP}/bootloader/system.img_b.raw 
      sudo -E ROOTFS_AB=1 ./tools/ota_tools/version_upgrade/l4t_generate_ota_package.sh -s --external-device nvme0n1 -S 34GiB jetson-orin-nano-devkit R36-4

Step 3: Observe the success log as:

      Write binary output file /home/rahul/Linux_for_Tegra/ota_base_dir_tmp/TEGRA_BL.Cap
      Success
      UEFI capsule is successfully generated at /home/rahul/Linux_for_Tegra/ota_base_dir_tmp/TEGRA_BL.Cap
      ./base_version
      ./board_name
      ./BOOTAA64.efi
      ./layout_change
      ./nv-l4t-bootloader-config.sh
      ./nv_ota_common.func
      ./nv_ota_common_utils.func
      ./nv_ota_customer.conf
      ./nv_ota_preserve_data.sh
      ./nv_ota_rootfs_updater.sh
      ./nv_ota_run_tasks.sh
      ./nv_ota_update_alt_part.func
      ./nv_ota_update_rootfs_in_recovery.sh
      ./nv_ota_update.sh
      ./nv_ota_validate.sh
      ./ota_nv_boot_control.conf
      ./ota_package.tar
      ./ota_package.tar.sha1sum
      ./TEGRA_BL.Cap
      ./update_control
      ./user_release_version
      ./version.txt
      SUCCESS: generate OTA package at "/home/(user)/Linux_for_Tegra/bootloader/jetson-orin-nano-devkit/ota_payload_package.tar.gz"

## Create Mender Artifact

Do the following:

      mender-artifact write rootfs-image \
      -t Jetson-orin-nx \
      -n jetson_orin_nx_adso_R00_01 \
      -f /../ota_payload_package.tar.gz \
      -o jetson_orin_nx_adso_R00_01.mender
      Log: 
      Writing Artifact...
      Version             	✓
      Manifest            	✓
      Manifest signature  	✓
      Header              	✓
      Payload
      .............................................................. - 100 %

## Important Info.
Inorder to utilize debug port USB-C, connect usb with PC and do:

      sudo minicom -D /dev/ttyUSB0 -b 115200

## To restore the persistence data:

Run the script:

      ./user_restore_profiles

Transfer and install locally using the command:

      sudo mender install /tmp/jetson_orin_nx_adso_R00_01.mender



