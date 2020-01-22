#!/bin/bash

# add RCE user group and its GID
sudo /usr/sbin/groupadd linux-sdusers -g 10000

# Change mounted folder permisions
sudo chown ${USER}:linux-sdusers $HOME/io
sudo chown ${USER}:linux-sdusers $HOME/jpred

# Change UID to real RCE user ID
sudo usermod -u $UID docker_user

# Finally let sudo ask for a passwd
#sudo sed 's/^/#/' /etc/sudoers.d/docker_user
