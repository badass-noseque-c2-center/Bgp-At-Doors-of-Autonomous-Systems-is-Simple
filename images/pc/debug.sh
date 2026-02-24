#!/bin/bash

set -e

/usr/sbin/sshd -D &

exec /bin/bash
