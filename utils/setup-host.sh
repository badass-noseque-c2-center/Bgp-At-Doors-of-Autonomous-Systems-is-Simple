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

install_dependencies() {
    if ! { dpkg -l | grep -q uml-utilities && dpkg -l | grep -q net-tools && dpkg -l | grep -q socat; }; then
	apt install -y uml-utilities net-tools socat
    fi
}

export -f setup_host_network install_dependencies

if ! ip addr | grep -qw $TAP_INTERFACE; then
    su -c setup_host_network
fi

su -c install_dependencies
