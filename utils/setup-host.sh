#!/bin/bash

set -exa

ADDRESS=$1
MASK=$2
TAP_INTERFACE=$3

setup_host_network() {
    set -ex
    chown root:netdev /dev/net/tun
    { id -nG $USER | grep -qw netdev; } || usermod -aG netdev $USER
    tunctl -u $USER -g netdev -t $TAP_INTERFACE;
    ifconfig $TAP_INTERFACE $ADDRESS netmask $MASK up;
}

install_docker() {
    # Add Docker's official GPG key:
    apt update
    apt install ca-certificates curl
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    #Add user to docker group
    groupadd docker || true
    usermod -aG docker $MY_USER
}

install_dependencies() {

    if ! { dpkg -l | grep -q uml-utilities && dpkg -l | grep -q net-tools && dpkg -l | grep -q socat; }; then
	apt update
	apt install -y uml-utilities net-tools socat
    fi

    if ! { dpkg -l | grep -q gns3-gui && dpkg -l | grep -q gns3-server; }; then
	add-apt-repository ppa:gns3/ppa \
	    && apt update \
	    && apt install gns3-gui gns3-server
    fi

    if ! { dpkg -l | grep -q openssh-server; }; then
	apt update
	apt install -y openssh-server \
	    && systemctl enable --now ssh
    fi

    if ! { dpkg -l | grep -q docker; }; then
	install_docker && systemctl enable --now docker
    fi
}

export -f setup_host_network install_dependencies install_docker

su -c install_dependencies

if ! ip addr show $TAP_INTERFACE | grep -q $ADDRESS; then
    su -c setup_host_network
fi
