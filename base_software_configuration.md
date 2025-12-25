# Getting Started

This file describes how to configure BSP for the Jetson reComputer Industrial J4011 board which can be used to create Golden Image for flashing.

## Prerequisites:

## Install the following libraries:
For example:

      sudo apt-get update
      sudo apt-get install build-essential flex bison libssl-dev
      sudo apt-get install sshpass
      sudo apt-get install abootimg
      sudo apt-get install nfs-kernel-server
      sudo apt-get install libxml2-utils
      sudo apt-get install qemu-user-static
      sudo apt install python-is-python3
      
## Preperations
### Download Jetson Linux
      wget https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v4.3/release/Jetson_Linux_r36.4.3_aarch64.tbz2
      tar xf Jetson_Linux_r36.4.3_aarch64.tbz2
### Download and extract sample root filesystem
      wget https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v4.3/release/Tegra_Linux_Sample-Root-Filesystem_r36.4.3_aarch64.tbz2
      sudo tar xpf Tegra_Linux_Sample-Root-Filesystem_r36.4.3_aarch64.tbz2 -C Linux_for_Tegra/rootfs/
### Sync source
      cd Linux_for_Tegra/source/
      ./source_sync.sh -t jetson_36.4.3
      cd ../..
### Clone and copy Seeed Studio's customizations
      mkdir -p github/Linux_for_Tegra
      git clone https://github.com/Seeed-Studio/Linux_for_Tegra.git -b r36.4.3 --depth=1 github/Linux_for_Tegra
      cp -r github/Linux_for_Tegra/* Linux_for_Tegra/
### Apply NVIDIA binaries
      cd Linux_for_Tegra
      sudo ./apply_binaries.sh
### Download and extract toolchain
      wget https://developer.nvidia.com/downloads/embedded/l4t/r36_release_v3.0/toolchain/aarch64--glibc--stable-2022.08-1.tar.bz2
      mkdir -p l4t-gcc
      tar xf aarch64--glibc--stable-2022.08-1.tar.bz2 -C ./l4t-gcc
### Export environment variables
      export ARCH=arm64
      export CROSS_COMPILE=$(realpath .)/l4t-gcc/aarch64--glibc--stable-2022.08-1/bin/aarch64-buildroot-linux-gnu-
      cd source
### Build kernel
      ./nvbuild.sh
### Copy kernel and modules
      ./do_copy.sh
### Set install path and build modules
      export INSTALL_MOD_PATH=$(realpath ../rootfs/)
      ./nvbuild.sh -i
### Replace with custom build configuration.
      SOURCE_XML= "../Linux_for_Tegra/tools/kernel_flash/flash_l4t_t234_nvme_rootfs_ab.xml"
      TARGET_XML = "./flash_l4t_t234_nvme_rootfs_ab.xml"
      cp "$SOURCE_XML" "$TARGET_XML
### Default user settings:
      sudo ./tools/l4t_create_default_user.sh -u araiv -p araiv -a -n araiv-link --accept-license
## Flashing
 For doing flashing, we have to put the Jetson into recovery mode.
 * Power off the Jetson board.
 * Connect the board to your host PC via USB (usually USB Type-C).
 * Press and hold the Force Recovery button.
 * While holding Force Recovery, press and release the Power button.
 * Release the Force Recovery button.
 * To ensure recovery mode, type lsusb in terminal.We should see an NVIDIA device listed (e.g., NVIDIA Corp.).

Do the following
      
      sudo ROOTFS_AB=1 ROOTFS_RETRY_COUNT_MAX=1 \
      ./tools/kernel_flash/l4t_initrd_flash.sh --external-device nvme0n1 \
      -S 34GiB -c tools/kernel_flash/flash_l4t_t234_nvme_rootfs_ab.xml -p \
      "-c bootloader/generic/cfg/flash_t234_qspi.xml" --showlogs \
      --network usb0 jetson-orin-nano-devkit internal


Once flashing is successful, enter inside Jetson terminal and type lsblk. We should see:
<pre><code>
      araiv@araiv-link:~$ lsblk
      NAME         MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
      zram0        252:0    0 952.6M  0 disk [SWAP]
      zram1        252:1    0 952.6M  0 disk [SWAP]
      zram2        252:2    0 952.6M  0 disk [SWAP]
      zram3        252:3    0 952.6M  0 disk [SWAP]
      nvme0n1      259:0    0 119.2G  0 disk 
      ├─nvme0n1p1  259:1    0    34G  0 part 
      ├─nvme0n1p2  259:2    0    34G  0 part /
      ├─nvme0n1p3  259:3    0   128M  0 part 
      ├─nvme0n1p4  259:4    0   768K  0 part 
      ├─nvme0n1p5  259:5    0  31.6M  0 part 
      ├─nvme0n1p6  259:6    0   128M  0 part 
      ├─nvme0n1p7  259:7    0   768K  0 part 
      ├─nvme0n1p8  259:8    0  31.6M  0 part 
      ├─nvme0n1p9  259:9    0    80M  0 part 
      ├─nvme0n1p10 259:10   0   512K  0 part 
      ├─nvme0n1p11 259:11   0    64M  0 part /boot/efi
      ├─nvme0n1p12 259:12   0    80M  0 part 
      ├─nvme0n1p13 259:13   0   512K  0 part 
      ├─nvme0n1p14 259:14   0    64M  0 part 
      ├─nvme0n1p15 259:15   0    20G  0 part /media/araiv/b44c52b5-dad9-485e-a8db-189bc6724537
      └─nvme0n1p16 259:16   0 479.5M  0 part 


Now Next chapter refers to Golden Image Preperation.