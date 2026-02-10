FROM debian:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    iproute2 \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -rm -d /home/gns3 -s /bin/bash -g root -G sudo -u 1000 gns3

RUN  echo 'gns3:gns3' | chpasswd

#ENTRYPOINT ["/usr/sbin/sshd", "-D"]
