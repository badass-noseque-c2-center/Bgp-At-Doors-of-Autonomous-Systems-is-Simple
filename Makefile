ROOT = .
UTILS_DIR = utils
PID_FILE = .pids

## ###################################################################
## DOCKER VARS
## ###################################################################

# Real addresses MUST be defined only in this file
BASE_ADDRESS ?= 10.0.10
PC_ADDRESS = $(BASE_ADDRESS).2
ROUTER_ADDRESS = $(BASE_ADDRESS).3
MASK ?= 255.255.255.0

## ###################################################################
## VM VARS
## ###################################################################
VM ?= qemu-system-x86_64
VM_IMAGE_LINK ?= https://releases.ubuntu.com/24.04.4/ubuntu-24.04.4-desktop-amd64.iso
VM_IMAGE ?= $(ROOT)/$(notdir $(VM_IMAGE_LINK))
VM_DRIVE ?= $(ROOT)/ubuntu.qcow2
VM_MOUNT ?= $(ROOT)
VM_CREATE_FLAGS =  -cdrom  $(VM_IMAGE)
VM_FLAGS =	-enable-kvm \
	        -m 4096 \
		-smp 4 \
	        -drive file=$(VM_DRIVE),if=virtio,format=qcow2 \
		-virtfs local,path=$(VM_MOUNT),mount_tag=p1,security_model=mapped-xattr \
	        -cpu host \
	        -machine q35 \
	        -device virtio-vga \
			-nic user,hostfwd=tcp::2250-:2250,hostfwd=tcp::2251-:2251 \
	        -display gtk

export MASK UTILS_DIR

build: build-pc build-router
build-debug: debug-pc debug-router

# Four options for this targets: build-pc build-router debug-pc debug-router
%-pc: FORCE
	$(MAKE) -C ./images/pc $* ROOT=../.. ADDRESS=$(PC_ADDRESS) \
	$(if $(findstring debug,$*),PORT=2250)

%-router: FORCE
	$(MAKE) -C ./images/router $* ROOT=../.. ADDRESS=$(ROUTER_ADDRESS) \
	$(if $(findstring debug,$*),PORT=2251)

setup-host:
	$(ROOT)/$(UTILS_DIR)/setup-host.sh $(BASE_ADDRESS).1 $(MASK)

container-debug: build-debug setup-host
	[ -f $(PID_FILE) ] && kill -9 $$(cat $(PID_FILE)) || true
	socat TCP-LISTEN:2230,fork TCP:localhost:2250 & echo -n "$$! " > $(PID_FILE)
	socat TCP-LISTEN:2231,fork TCP:localhost:2251 & echo -n "$$! " >> $(PID_FILE)

# Two options for this target: vm-start vm-create
vm-%: FORCE | $(VM_DRIVE) $(VM_IMAGE)
	$(VM) $(VM_FLAGS) $(if $(findstring create,$*),$(VM_CREATE_FLAGS))

$(VM_DRIVE):
	qemu-img create -f qcow2 $@ 30G

$(VM_IMAGE):
	wget $(VM_IMAGE_LINK)

FORCE:

.PHONY: build build-debug setup-host container-debug
