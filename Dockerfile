# Origin of the image
FROM ubuntu:18.04

# Declare non privileged user for our container
ARG USER=docker_user

## Set Container user group for convenience
ENV USER_GROUP=linux_sduser

## Container Group ID
ENV GID=10000

## Container User name
ENV USER=$USER

## Set Container user ID our current user ID
ENV UID=$UID

# Install packages
RUN apt-get update && \
 apt-get install -y \
 man tcsh wget vim sudo make gcc hmmer clustalw perl build-essential cpanminus 

# Create group and unpriviledge user and add it to sudoers without password
RUN groupadd $GID 
RUN useradd --create-home --shell /bin/bash $USER && \
    echo "$USER:protein" | chpasswd && \
    adduser $USER sudo && \
    echo "$USER ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USER && \
    chmod 0440 /etc/sudoers.d/$USER 

# Declare working directory
WORKDIR /home/$USER

# Upload entry point script
COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s /usr/local/bin/docker-entrypoint.sh /

# Default command
CMD ["/bin/bash"]

# Run the entry point and keep alive with a bash
ENTRYPOINT docker-entrypoint.sh && bash
