FROM docker.io/fedora:30 AS bitcoind-dev

RUN dnf install -y --nodocs \
    gcc-c++ \
    libtool \
    make \
    which \
    git \
    wget \
    patch \
    file \
    openssl-devel \
    libevent-devel \
    boost-devel \
    zeromq-devel

RUN mkdir -p /build/files; \
    cd build; \
    git clone --branch 0.18 https://github.com/bitcoin/bitcoin; \
    cd bitcoin; \
    ./autogen.sh; \
    ./contrib/install_db4.sh `pwd`; \
    export BDB_PREFIX='/build/bitcoin/db4'; \
    ./configure BDB_LIBS="-L${BDB_PREFIX}/lib -ldb_cxx-4.8" BDB_CFLAGS="-I${BDB_PREFIX}/include" --disable-tests  --disable-bench; \
    make check

RUN cd /build/bitcoin; \
    strip src/bitcoind && cp src/bitcoind ../files; \
    strip src/bitcoin-cli && cp src/bitcoin-cli ../files; \
    strip src/bitcoin-tx && cp src/bitcoin-tx ../files; \
    strip src/bitcoin-wallet && cp src/bitcoin-wallet ../files; \
    cp share/rpcauth/rpcauth.py ../files; \
    echo "datadir=/srv" >> share/examples/bitcoin.conf

FROM docker.io/fedora:30 

RUN dnf install -y --nodocs \
    openssl \
    libevent \
    boost \
    zeromq; \
    dnf clean all; \
    mkdir /root/.bitcoin

COPY --from=bitcoind-dev /build/files/* /usr/bin/
COPY --from=bitcoind-dev /build/bitcoin/share/examples/bitcoin.conf /root/.bitcoin

VOLUME /root/.bitcoin

EXPOSE 8332 8333

ENTRYPOINT ["bitcoind"]
