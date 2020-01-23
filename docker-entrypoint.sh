#!/bin/bash

# add RCE user group and its GID
sudo /usr/sbin/groupadd ${USER_GROUP} -g ${GID}

# Change mounted folder permisions
sudo chown ${USER}:${GID} ${HOME}/io
sudo chown ${USER}:${GID} ${HOME}/jpred

# Change UID to real RCE user ID
sudo usermod -u ${UID} ${USER}

# Finally let sudo ask for a passwd
#sudo sed 's/^/#/' /etc/sudoers.d/docker_user
