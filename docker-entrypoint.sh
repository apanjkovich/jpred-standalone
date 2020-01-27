#!/bin/bash

# Add user group and its GID inside the container
# The here is controlling ownership of files produced 
sudo /usr/sbin/groupadd ${USER_GROUP} -g ${GID}

# Change mounted folder permisions
# By default thos folders inside the docker container
# belong to root
sudo chown ${USER}:${USER_GROUP} ${HOME}/io
sudo chown ${USER}:${USER_GROUP} ${HOME}/jpred

# Change container UID to match host system user ID
sudo usermod -u ${UID} ${USER}

# Finally let sudo ask for a passwd (if needed)
#sudo sed 's/^/#/' /etc/sudoers.d/docker_user
