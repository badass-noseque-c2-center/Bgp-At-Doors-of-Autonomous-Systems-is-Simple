ROOT = .
UTILS_DIR = utils

include $(ROOT)/$(UTILS_DIR)/utils.mk

## ###################################################################
## DOCKER VARS
## ###################################################################
IMAGES := $(notdir $(wildcard $(ROOT)/images/*))
BASE_ADDRESS ?= 10.0.10
BRIDGED_PORTS := $(call sum_ports,$(IMAGES),2230)
GATEWAY ?= $(BASE_ADDRESS).1
MASK ?= 255.255.255.0
TAP_INTERFACE ?= tap0

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
	        -display gtk \
		-nic user,hostfwd=tcp::2222-:22$(subst $(space),,$(foreach port,$(BRIDGED_PORTS),,hostfwd=tcp::$(port)-:$(port)))

export MASK UTILS_DIR GATEWAY BASE_ADDRESS

$(foreach image-port,$(join $(IMAGES),$(addprefix /,$(BRIDGED_PORTS))),$(eval $(call machine_template,$(subst /$(notdir $(image-port)),,$(image-port)),$(notdir $(image-port)))))

check-host:
	@if ! ip addr show tap0 | grep -q $(GATEWAY); then \
		echo "Host is not configured! Run 'make setup-host'."; \
		exit 1; \
	fi

setup-host:
	chmod +x $(ROOT)/$(UTILS_DIR)/setup-host.sh
	MY_USER=$(USER) $(ROOT)/$(UTILS_DIR)/setup-host.sh $(GATEWAY) $(MASK) $(TAP_INTERFACE)

# Two options for this target: vm-start vm-create
vm-start vm-create: vm-%: | $(VM_DRIVE) $(VM_IMAGE)
	$(VM) $(VM_FLAGS) $(if $(findstring create,$*),$(VM_CREATE_FLAGS))

$(VM_DRIVE):
	qemu-img create -f qcow2 $@ 30G

$(VM_IMAGE):
	wget $(VM_IMAGE_LINK)

.PHONY: build debug setup-host
