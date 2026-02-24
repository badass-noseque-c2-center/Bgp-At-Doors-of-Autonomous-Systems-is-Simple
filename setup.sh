#!/bin/bash

if [ "$1" == "" ]; then
	echo "usage: ./setup.sh [create|start]" 1>&2
	exit 1
fi


if [ "$1" == "create" ]; then

    qemu-img create -f qcow2 ubuntu.qcow2 30G

    qemu-system-x86_64 \
        -enable-kvm \
        -m 4096 \
        -cdrom ubuntu-24.04.3-desktop-amd64.iso \
        -drive file=ubuntu.qcow2,if=virtio,format=qcow2 \
        -cpu host \
        -machine q35 \
        -device virtio-vga \
        -display gtk
fi

if [ "$1" == "start" ]; then
    qemu-system-x86_64 \
      -enable-kvm \
      -m 4096 \
      -cpu host \
      -smp 4 \
      -drive file=ubuntu.qcow2,format=qcow2 \
      -virtfs local,path=p1,mount_tag=p1,security_model=mapped-xattr \
      -device virtio-vga \
      -display gtk
fi

# sudo mount -t 9p -o trans=virtio,version=9p2000.L shared /mnt/shared