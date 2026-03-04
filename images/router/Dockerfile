FROM debian:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    sudo \
    iproute2 \
    iputils-ping \
    net-tools \
    frr \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -rm -d /home/gns3 -s /bin/bash -g root -G sudo -u 1000 gns3

RUN echo 'gns3:gns3' | chpasswd

COPY config/  /etc/frr/

COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/debug.sh"]
