ROOT = .
UTILS_DIR = utils
PID_FILE = .pids

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
	[ -f $(PID_FILE) ] && kill -9 $$(cat $(PID_FILE))
	socat TCP-LISTEN:2230,fork TCP:localhost:2250 & echo -n "$$! " > $(PID_FILE)
	socat TCP-LISTEN:2231,fork TCP:localhost:2251 & echo -n "$$! " >> $(PID_FILE)

.PHONY: build build-pc build-router cosa
