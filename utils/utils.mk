space = $() $()

check_defined = $(foreach var,$(sort $(strip $(1))),$(if $(value $(var)),,$(error Undefined variable: $(var))))

# Render the machine template that will contain tokens <ADDRESS> and <MASK>
# Args:
# $(1) => Template name (suffixed with .template)
render_machine_template = sed \
	$(if $(value ADDRESS),-e "s/<ADDRESS>/$(ADDRESS)/g") \
	$(if $(value MASK),-e "s/<MASK>/$(MASK)/g") \
	$(if $(value GATEWAY),-e "s/<GATEWAY>/$(GATEWAY)/g") \
	$(if $(value SSH_PORT),-e "s/<SSH_PORT>/$(SSH_PORT)/g") \
	$(1) > $(basename $(1))


# Bridge the docker container connections for debug
# Args:
# $(1) => Address
# $(2) => Listen port
# $(3) => Read port
define bridge_connection
	MATCHED_PID=$$(ss -lptn | awk -F',pid=|,' '/:$(2)/{print $$2}') \
	&& if [ -n "$$MATCHED_PID" ]; then kill -9 $$MATCHED_PID; fi
	socat TCP-LISTEN:$(2),fork TCP:$(1):$(3) &
 endef

# Genetate a list of ports n times where n is the lenght of the list
# 1 -> list of items
# 2 -> base port
sum_ports = $(shell i=$(2); for item in $(1); do echo $$i; i=$$(($$i+1)); done)

# 1 -> machine name
# 2 -> ssh port
define machine_template =
build: build-$(1)

debug: debug-$(1)

build-$(1): check-host
	$(MAKE) -C ./images/$(1) build ROOT=../.. BRIDGE_PORT=$(2) SSH_PORT=$$$$(($(2) + 20))

debug-$(1):
	$(MAKE) -C ./images/$(1) debug ROOT=../.. ADDRESS=localhost BRIDGE_PORT=$(2) SSH_PORT=$$$$(($(2) + 20))

clean-$(1):
	$(MAKE) -C ./images/$(1) clean ROOT=../.. BRIDGE_PORT=$(2) SSH_PORT=$$$$(($(2) + 20))

endef
