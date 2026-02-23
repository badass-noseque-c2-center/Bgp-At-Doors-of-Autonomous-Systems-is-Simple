#!/bin/bash

set -exa

ADDRESS=$1
MASK=$2

setup_host_network() {
set -ex
chown root:netdev /dev/net/tun
{ id -nG $USER | grep -qw netdev; } || useradd -g $USER netdev
if ! ip addr | grep -qw tap0; then
    tunctl -u $USER -g netdev -t tap0;
    ifconfig tap0 $ADDRESS netmask $MASK up;
fi
}

export -f setup_host_network

su -c setup_host_network
