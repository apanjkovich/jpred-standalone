
# Origin of the image
FROM ubuntu:18.04

# Install packages
RUN apt-get update && \
 apt-get install -y \
 man tcsh wget vim sudo make gcc hmmer clustalw perl build-essential cpanminus 

# Declare user variable
ARG USER=docker_user

# Declare image environment vars
ENV UID=${UID}
ENV GID=10000
ENV USER=$USER

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
