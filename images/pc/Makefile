$(call check_defined,ADDRESS MASK UTILS_DIR ROOT)

include $(ROOT)/$(UTILS_DIR)/utils.mk

TEMPLATE = ./entrypoint.sh.template
NAME = gns3_pc

$(shell $(call render_machine_template,$(TEMPLATE)))

# Docker build/debug targets are generic, just include them
include $(ROOT)/$(UTILS_DIR)/docker-generic.mk

.PHONY: build debug clean
