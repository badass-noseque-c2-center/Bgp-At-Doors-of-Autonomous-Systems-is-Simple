ROOT = .
UTILS = utils/utils.mk

BASE_ADDRESS ?= 10.0.10
MASK ?= 255.255.255.0

export MASK UTILS

build: build_pc build_router

build_pc:
	$(MAKE) -C ./images/pc build ROOT=../.. ADDRESS=$(BASE_ADDRESS).1

build_router:
	$(MAKE) -C ./images/router build ROOT=../.. ADDRESS=$(BASE_ADDRESS).2

.PHONY: build build_pc build_router
