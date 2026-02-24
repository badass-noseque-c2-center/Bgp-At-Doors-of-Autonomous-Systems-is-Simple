check_defined = $(foreach var,$(sort $(strip $(1))),$(if $(value $(var)),,$(error Undefined variable: $(var))))

# Render the machine template that will contain tokens <ADDRESS> and <MASK>
# Args:
# $(1) => Template name (suffixed with .template)
render_machine_template = sed \
	$(if $(value ADDRESS),-e "s/<ADDRESS>/$(ADDRESS)/g") \
	$(if $(value MASK),-e "s/<MASK>/$(MASK)/g") \
	$(1) > $(basename $(1))
