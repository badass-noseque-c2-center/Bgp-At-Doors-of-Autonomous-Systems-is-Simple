#!/bin/bash

set -e

/usr/lib/frr/frrinit.sh start &> /var/log/frr/frr.log &

exec /usr/sbin/sshd -D
