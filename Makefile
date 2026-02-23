ROOT = .
UTILS = utils/utils.mk

BASE_ADDRESS ?= 10.0.10
MASK ?= 255.255.255.0

export MASK UTILS

all:
	$(MAKE) -C ./images/pc build ROOT=../.. ADDRESS=$(BASE_ADDRESS).1
