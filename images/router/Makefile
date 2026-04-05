$(call check_defined,ADDRESS MASK UTILS_DIR ROOT)

include $(ROOT)/$(UTILS_DIR)/utils.mk

TEMPLATE = .env.template
NAME ?= gns3_router
ADDRESS ?= $(BASE_ADDRESS).3
SSH_PORT ?= 2251
BRIDGE_PORT ?= 2231

$(shell $(call render_machine_template,$(TEMPLATE)))

# Docker build/debug targets are generic, just include them
include $(ROOT)/$(UTILS_DIR)/docker-generic.mk

.PHONY: build debug clean bridge
