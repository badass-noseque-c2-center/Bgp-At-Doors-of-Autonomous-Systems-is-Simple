include $(ROOT)/$(UTILS)

TEMPLATE = ./entrypoint.sh.template

$(call check_defined,ADDRESS MASK UTILS ROOT)
$(shell $(call render_machine_template,$(TEMPLATE)))

build:
	docker build -t gns3_pc .

.PHONY: build
