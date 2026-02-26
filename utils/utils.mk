check_defined = $(foreach var,$(sort $(strip $(1))),$(if $(value $(var)),,$(error Undefined variable: $(var))))

# Render the machine template that will contain tokens <ADDRESS> and <MASK>
# Args:
# $(1) => Template name (suffixed with .template)
render_machine_template = sed \
	$(if $(value ADDRESS),-e "s/<ADDRESS>/$(ADDRESS)/g") \
	$(if $(value MASK),-e "s/<MASK>/$(MASK)/g") \
	$(1) > $(basename $(1))


# Bridge the docker container connections for debug
# Args:
# $(1) => Listen port
# $(2) => Read port
define bridge_connection
	MATCHED_PID=$$(ss -lptn | awk -F',pid=|,' '/:$(1)/{print $$2}') \
	&& if [ -n "$$MATCHED_PID" ]; then kill -9 $$MATCHED_PID; fi
	socat TCP-LISTEN:$(1),fork TCP:localhost:$(2) &
 endef
