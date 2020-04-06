FROM docker.io/buildpack-deps:buster-scm AS bitcoind-dev

RUN apt-get update; \
    apt-get install --no-install-recommends --no-install-suggests -y \
      build-essential \
      libtool \
      autotools-dev \
      automake \
      pkg-config \
      bsdmainutils \
      python3; \
    apt-get install --no-install-recommends --no-install-suggests -y \
      libssl-dev \
      libevent-dev \
      libboost-system-dev \
      libboost-filesystem-dev \
      libboost-chrono-dev \
      libboost-test-dev \
      libboost-thread-dev \
      libzmq3-dev

RUN mkdir -p /build/files; \
    cd build/; \
    git clone --branch 0.19 https://github.com/bitcoin/bitcoin; \
    cd bitcoin/; \
    ./autogen.sh; \
    ./contrib/install_db4.sh `pwd`; \
    export BDB_PREFIX='/build/bitcoin/db4'; \
    ./configure BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" BDB_CFLAGS="-I${BDB_PREFIX}/include" --disable-tests  --disable-bench; \
    make check; \
    cd /build/bitcoin; \
    strip src/bitcoind && cp src/bitcoind ../files; \                                                                                                 
    strip src/bitcoin-cli && cp src/bitcoin-cli ../files; \                                                                                           
    strip src/bitcoin-tx && cp src/bitcoin-tx ../files; \                                                                                             
    strip src/bitcoin-wallet && cp src/bitcoin-wallet ../files; \                                                                                     
    cp share/rpcauth/rpcauth.py ../files                                                                                                              

FROM docker.io/debian:buster

RUN apt-get update; \
    apt-get install --no-install-recommends --no-install-suggests -y \
      libssl-dev \
      libevent-dev \
      libboost-system-dev \
      libboost-filesystem-dev \
      libboost-chrono-dev \
      libboost-test-dev \
      libboost-thread-dev \
      libzmq3-dev; \
    apt-get clean && rm -rf /var/lib/apt/lists/*; \
    mkdir /root/.bitcoin                                                                                                                              

COPY --from=bitcoind-dev /build/files/* /usr/bin/                                                                                                     
COPY --from=bitcoind-dev /build/bitcoin/share/examples/bitcoin.conf /root/.bitcoin                                                                    
                                                                                                                                                      
VOLUME /root/.bitcoin                                                                                                                                 
                                                                                                                                                      
EXPOSE 8333 8333                                                                                                                                      
                                                                                                                                                      
ENTRYPOINT ["bitcoind"]      
