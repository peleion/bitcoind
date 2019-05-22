# bitcoind-docker

Docker to build bitcoind (core) from source using Fedora. It pulls the latest production sources from github, compiles from source (including backward-compatible BerkeleyDB for old wallets) then copies executables to a new docker to minimize container/image size.

You must be running at least Docker version 17.05 to create the image as this utilizes a multistage build. You could split the Dockerfile into two separate passes if you want to develop using an older version. The final container should be able to run on any version of Docker.

This Docker should run on a user-defined Docker network if you want to use any other bitcoin-related services (ElectrumX, EPS, etc) to allow inter-container communications.

The Docker:

1. Uses a persistent volume to store the bitcoin data
2. Moves the config file to the persistent volume. Links are created to the Docker /root/.bitcoin directory to allow bitcoin-cli to function properly/easily
3. Calls bitcoind from a helper script to ensure #2 works properly

A docker-compose is included - you will need to modify it.

TODO:

Automated docker build on DockerHub

