# bitcoind-docker

Dockerfile and supporting files to build bitcoind (core) from source using Fedora. It pulls the latest production sources from github, compiles them (including backward-compatible BerkeleyDB for old wallets and ZMQ for future lightning node use) then copies executables to a new docker to minimize final container/image size.

You must be running at least Docker version 17.05 to create the image as this utilizes a multistage build. You could split the Dockerfile into two separate passes if you want to develop using an older version. The final container should be able to run on any version of Docker.

This container should utilize a user-defined Docker network if you want to use any other bitcoin-related services (ElectrumX, EPS, etc) to allow inter-container communications.

A sample docker-compose is included - you will need to modify it.

This Docker:

1. Uses a persistent volume to store the bitcoin data relocated to /srv
2. Moves bitcoin.conf to the persistent volume and adds the appropriate pointer to the persistent data. The sample bitcoin.conf included in GitHub source is used. Links are created on each startup to allow bitcoin-cli to function properly
3. Calls bitcoind from a helper script to ensure #2 and #3 work properly

---
TODO:

Automated image build on DockerHub

