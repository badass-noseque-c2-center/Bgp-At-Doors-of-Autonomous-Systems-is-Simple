#!/bin/bash

set -exa

setup_host_network() {
set -ex
chown root:netdev /dev/net/tun
id -nG $USER | grep -qw netdev && useradd -g $USER netdev
if ! ip addr | grep -qw tap0; then
    tunctl -u $USER -g netdev -t tap0;
    ifconfig tap0 $NEXT_ADDRESS netmask $MASK up;
fi
}

export -f setup_host_network

BASE_ADDRESS=${1:-10.0.10.}
MASK=${2:-255.255.255.0}
LAST_BYTE=0
BASE_DIR=$(pwd)
NEXT_ADDRESS=$BASE_ADDRESS$((++LAST_BYTE))

su -c setup_host_network

NEXT_ADDRESS=$BASE_ADDRESS$((++LAST_BYTE))
sed -e "s/<ADDRESS>/$NEXT_ADDRESS/g" \
    -e "s/<MASK>/$MASK/g" \
    entrypoint.sh.template > entrypoint.sh
docker build -t gns3debian .
socat TCP-LISTEN:2222,fork TCP:$NEXT_ADDRESS:22
