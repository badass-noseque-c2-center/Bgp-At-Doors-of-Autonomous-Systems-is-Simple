FROM debian:latest

ARG ADDRESS="10.0.0.2"
ARG NETMASK="24"
ARG DEFAULT_GATEWAY="10.0.0.1"

RUN apt update && apt install -y iproute2 && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /etc/network/ && touch /etc/network/interfaces
COPY <<EOF /etc/network/interfaces
auto eth0
iface eth0 inet static
	address ${ADDRESS}
	netmask ${NETMASK}
	gateway ${DEFAULT_GATEWAY}
EOF

ENTRYPOINT ["sleep", "infinity"]