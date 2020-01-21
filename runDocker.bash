docker run -d -it -v /home/apanjkovich/extdata/blastdb:/home/docker_user/mounted/blastdb -v /home/apanjkovich/fsync/Docker/jpredDocker/jpred:/home/docker_user/jpred --user docker_user:10000 -e UID=$(id -u) --name  jpredcontainer2  jpredimage2:latest

