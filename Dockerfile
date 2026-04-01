FROM ubuntu:20.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    build-essential \
    cmake \
    git \
    pkg-config \
    ca-certificates \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libncurses-dev \
    default-libmysqlclient-dev \
    libboost-all-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . /app

RUN rm -rf build-docker && \
    mkdir build-docker && \
    cd build-docker && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    cmake --build . -j"$(nproc)" && \
    cmake --install .

FROM ubuntu:20.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    libssl1.1 \
    zlib1g \
    libbz2-1.0 \
    libreadline8 \
    libncurses6 \
    libmysqlclient21 \
    libboost-filesystem1.71.0 \
    libboost-program-options1.71.0 \
    libboost-system1.71.0 \
    libboost-thread1.71.0 \
    libboost-iostreams1.71.0 \
    libboost-regex1.71.0 \
    ca-certificates \
    curl \
    unzip \
    p7zip-full \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/legioncore

COPY --from=builder /usr/local/bin/worldserver /usr/local/bin/worldserver
COPY --from=builder /usr/local/bin/bnetserver /usr/local/bin/bnetserver
COPY --from=builder /usr/local/bin/bnetserver.cert.pem /usr/local/bin/bnetserver.cert.pem
COPY --from=builder /usr/local/bin/bnetserver.key.pem /usr/local/bin/bnetserver.key.pem
COPY --from=builder /usr/local/etc/worldserver.conf.dist /usr/local/etc/worldserver.conf.dist
COPY --from=builder /usr/local/etc/bnetserver.conf.dist /usr/local/etc/bnetserver.conf.dist
COPY docker/runtime/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh && \
    mkdir -p /usr/local/bin /usr/local/etc /opt/legioncore/logs

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/local/bin/worldserver"]
