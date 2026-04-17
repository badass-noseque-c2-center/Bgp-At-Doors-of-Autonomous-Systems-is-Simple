#!/bin/bash

set -e

# Manual interface configuration, if 10.0.10.3 == localhost we are debugging
# so no network configuration is needed.
if [ "$ADDRESS" != "localhost" ]; then
    ifconfig eth0 $ADDRESS netmask $MASK up
    ip route add default via $GATEWAY dev eth0
fi

exec /usr/sbin/sshd -p $SSH_PORT -D
