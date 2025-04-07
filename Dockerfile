FROM debian:bookworm-slim AS builder

RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    cmake \
    libuv1-dev \
    libssl-dev \
    libhwloc-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
RUN git clone https://github.com/xmrig/xmrig.git

WORKDIR /build/xmrig
RUN mkdir build && cd build && \
    cmake .. && \
    make

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --break-system-packages flask waitress

WORKDIR /app
COPY --from=builder /build/xmrig/build/xmrig .

COPY config.json .

EXPOSE 8080

CMD ["./xmrig", "-c", "config.json"]
