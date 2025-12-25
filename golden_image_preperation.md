
# Base System Configuration.

Base Software has following installations / configurations.

      ✅ Mender client
      ✅ Static IP setup
      ✅ CAN SocketCAN interface
      ✅ Podman 
      ✅ Data partition mount  


## Mender Client

curl -fLsS https://get.mender.io -o get-mender.sh

Or refer to the latest mender client installation in the mender homepage.

After that, Please replace the mender client configuraiton from the following path with the file in the artifactory.
/etc/mender 

      sudo cp mender.conf /etc/mender/

Verify:

      sudo systemctl status mender-authd
      sudo systemctl status mender-updated



## Static IP set up.
The following files from this repository need to be copied to the Jetson.

      sudo cp NetworkManager.conf /etc/NetworkManager/
      sudo cp -r system-connections /etc/NetworkManager/

### Network set up.
Do the following:

      nmcli connection up lan_dhcp /* Only if we want to enable local LAN connection, for testing purpose*/
      nmcli connection up vehicle
      nmcli connection up zms_router

      sudo chmod 600 /etc/NetworkManager/system-connections/vehicle.nmconnection 
      sudo chmod 600 /etc/NetworkManager/system-connections/zms_router.nmconnection
      sudo chmod 600 /etc/NetworkManager/system-connections/lan_dhcp.nmconnection 

      sudo nmcli connection reload
      nmcli connection up vehicle 

      sudo nmcli connection reload
      nmcli connection up zms_router 

## CAN SocketCAN interface

      sudo apt update
      sudo apt install can-utils


Can adapter bring up


      sudo ip link set can0 type can bitrate 500000
      sudo ip link set can0 up


Or,

Copy the artifactory file socketcan.service into the following directory as below.

      sudo cp socketcan.service /etc/systemd/system/

Do

      sudo systemctl daemon-reexec
      sudo systemctl daemon-reload
      sudo systemctl enable socketcan.service
      sudo systemctl start socketcan.service
      sudo systemctl enable socketcan.service

## Podman

      sudo apt install -y podman
      podman info --debug

## Creating the update module

      sudo mkdir -p /usr/share/mender/modules/v3
      sudo touch  /usr/share/mender/modules/v3/rootfs-image-jetson

copy the artifactory file rootfs-image-jetson.sh in to this path.

      sudo cp rootfs-image-jetson.sh /usr/share/mender/modules/v3/
      chmod +x /usr/share/mender/modules/v3/rootfs-image-jetson

## Copy mender identity file
From the artifactory, copy identity-mac.sh into the location as below

      sudo cp identity-mac.sh /usr/share/mender/identity/

## Modify keyring settings.

Edit sudo nano /etc/sysctl.d/99-keys.conf with below values.

      kernel.keys.maxkeys=200000
      kernel.keys.maxbytes=2500000

Apply changes immediately by

      sudo sysctl --system

## install build essentials.

      sudo apt update
      sudo apt install build-essential
      
Next chapter is mender_ota_update.md