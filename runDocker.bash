docker run -d -it -v $HOME/jpred-standalone/data:/home/docker_user/mounted/blastdb --user docker_user:10000 -e UID=$(id -u) --name  jpredcontainer2  jpredimage2:latest

