ROOT = .
UTILS_DIR = utils

include $(ROOT)/$(UTILS_DIR)/utils.mk

## ###################################################################
## DOCKER VARS
## ###################################################################

BASE_ADDRESS ?= 10.0.10
GATEWAY ?= $(BASE_ADDRESS).1
MASK ?= 255.255.255.0
TAP_INTERFACE ?= tap0

# This variables are defined in the module-specific makefile:
# ADDRESS ?= 
# SSH_PORT ?= 
# BRIDGE_PORT ?= 

## ###################################################################
## VM VARS
## ###################################################################
VM ?= qemu-system-x86_64
VM_IMAGE_LINK ?= https://releases.ubuntu.com/24.04.4/ubuntu-24.04.4-desktop-amd64.iso
VM_IMAGE ?= $(ROOT)/$(notdir $(VM_IMAGE_LINK))
VM_DRIVE ?= $(ROOT)/ubuntu.qcow2
VM_MOUNT ?= $(ROOT)
VM_MOUNT_TAG ?= resources
VM_CREATE_FLAGS =  -cdrom  $(VM_IMAGE)
VM_FWD_PORTS = 	-nic user,hostfwd=tcp::2230-:2230,hostfwd=tcp::2231-:2231,hostfwd=tcp::2232-:2232,hostfwd=tcp::2233-:2233,hostfwd=tcp::2234-:2234,hostfwd=tcp::2235-:2235
VM_FLAGS =	-enable-kvm \
	        -m 4096 \
			-smp 4 \
	        -drive file=$(VM_DRIVE),if=virtio,format=qcow2 \
			-virtfs local,path=$(VM_MOUNT),mount_tag=$(VM_MOUNT_TAG),security_model=mapped-xattr \
	        -cpu host \
	        -machine q35 \
	        -device virtio-vga \
			-display gtk \
			$(VM_FWD_PORTS)

export MASK UTILS_DIR GATEWAY BASE_ADDRESS

build: build-pc build-router
debug: debug-pc debug-router

# Four options for this targets: build-pc build-router debug-pc debug-router
build-pc build-router: build-%: check-host
	$(MAKE) -C ./images/$* build ROOT=../..

debug-pc debug-router: debug-%:
	$(MAKE) -C ./images/$* debug ROOT=../.. ADDRESS=localhost

clean-pc clean-router: clean-%:
	$(MAKE) -C ./images/$* clean ROOT=../..

check-host:
	@if ! ip addr show tap0 | grep -q $(GATEWAY); then \
		echo "Host is not configured! Run 'make setup-host'."; \
		exit 1; \
	fi

setup-host:
	chmod +x $(ROOT)/$(UTILS_DIR)/setup-host.sh
	$(ROOT)/$(UTILS_DIR)/setup-host.sh $(GATEWAY) $(MASK) $(TAP_INTERFACE)

# Two options for this target: vm-start vm-create
vm-start vm-create: vm-%: | $(VM_DRIVE) $(VM_IMAGE)
	$(VM) $(VM_FLAGS) $(if $(findstring create,$*),$(VM_CREATE_FLAGS))

mount-host:
	@echo "sudo mount -t -9p -o trans=virtio,version=9p2000.L $(VM_MOUNT_TAG) /mnt/$(VM_MOUNT_TAG)"

$(VM_DRIVE):
	qemu-img create -f qcow2 $@ 30G

$(VM_IMAGE):
	wget $(VM_IMAGE_LINK)

.PHONY: build debug setup-host mount-host

.DEFAULT:
	@echo Docker image creation for router & host &&  network configuration

	@echo "build:         Build router and host images."
	@echo "debug:         Build router and host images in debug mode."
	@echo "build-pc:      Build only the host image."
	@echo "build-router:  Build only the router image."
	@echo "debug-pc:      Build only the host image (debug mode)"
	@echo "debug-router:  Build only the router image (debug mode)"
	@echo "clean-pc:      
	@echo "clean-router:
	@echo "setup-host:
	@echo "vm-start:
	@echo "mount-host:
