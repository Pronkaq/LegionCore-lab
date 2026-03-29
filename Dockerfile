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
    default-mysql-client \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/legioncore

COPY --from=builder /usr/local/bin/worldserver /opt/legioncore/bin/worldserver
COPY --from=builder /usr/local/bin/bnetserver /opt/legioncore/bin/bnetserver
COPY --from=builder /usr/local/bin/bnetserver.cert.pem /opt/legioncore/bin/bnetserver.cert.pem
COPY --from=builder /usr/local/bin/bnetserver.key.pem /opt/legioncore/bin/bnetserver.key.pem
COPY --from=builder /usr/local/etc/worldserver.conf.dist /opt/legioncore/etc/worldserver.conf.dist
COPY --from=builder /usr/local/etc/bnetserver.conf.dist /opt/legioncore/etc/bnetserver.conf.dist
COPY docker/runtime/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh && \
    mkdir -p /opt/legioncore/bin /opt/legioncore/etc /opt/legioncore/logs

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/opt/legioncore/bin/worldserver"]
