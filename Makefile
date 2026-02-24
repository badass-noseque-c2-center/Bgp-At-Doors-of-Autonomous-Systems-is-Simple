ROOT = .
UTILS_DIR = utils

# Real addresses MUST be defined only in this file
BASE_ADDRESS ?= 10.0.10
PC_ADDRESS = $(BASE_ADDRESS).2
ROUTER_ADDRESS = $(BASE_ADDRESS).3
MASK ?= 255.255.255.0

export MASK UTILS_DIR

build: build-pc build-router
build-debug: debug-pc debug-router

%-pc:
	$(MAKE) -C ./images/pc $* ROOT=../.. ADDRESS=$(PC_ADDRESS) \
	$(if $(findstring debug,$*),PORT=2250)

%-router:
	$(MAKE) -C ./images/router $* ROOT=../.. ADDRESS=$(ROUTER_ADDRESS) \
	$(if $(findstring debug,$*),PORT=2251)

setup-host:
	$(ROOT)/$(UTILS_DIR)/setup-host.sh $(BASE_ADDRESS).1 $(MASK)

container-debug: build-debug setup-host
	socat TCP-LISTEN:2230,fork TCP:localhost:2250 & echo "Router pid: $$!"
	socat TCP-LISTEN:2231,fork TCP:localhost:2251 & echo "Router pid: $$!"

.PHONY: build build-pc build-router cosa
