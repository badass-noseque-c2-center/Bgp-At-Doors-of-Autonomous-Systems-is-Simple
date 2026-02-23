ROOT = .
UTILS = utils/utils.mk
ADDRESS = 10.0.0.1
MASK = 255.255.255.0

export ADDRESS MASK UTILS

all:
	$(MAKE) -C ./images/pc build ROOT=../..
