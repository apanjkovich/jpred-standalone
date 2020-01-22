# jpred-standalone
docker image for running standalone jpred

INSTRUCTIONS

I. Initialization and testing

1. BUILD the image:
```
docker build -t jpredimage2 .
```

2. RUN container and mount corresponding volumes:
```
docker run -d -it -v $(pwd)/data:/home/docker_user/data -v $(pwd)/io:/home/docker_user/io -v $(pwd)/jpred:/home/docker_user/jpred --user docker_user:10000 -e UID=$(id -u) --name  jpredcontainer2  jpredimage2:latest

```

3. EXEC jpred using docker EXEC command: 
```
docker exec -it jpredcontainer2 /home/docker_user/jpred/jpred --sequence io/example_protein.fasta --db kinases --output io/testing
```
  -A set of testing.xxx files should be quickly produced as output. 
  -`testing.jnet` contains the SS and burial predictions.
  -This step can be repeated for processing multiple sequences.
	

II. Usage

1. Prepare your data files
  -Place the provided blast database in the 'data' directory.
  -Place your query sequences in fasta format in the 'io' directory.

2. Execute jpred by running the EXEC jpred command on each of your query sequences (ie replace 'sequenceX' with your ids:
```
docker exec -it jpredcontainer2 /home/docker_user/jpred/jpred --sequence io/sequenceX.fasta --db uniref.filt --output io/sequenceX
```

Run time when using the uniref.filt database can be a few hours.


