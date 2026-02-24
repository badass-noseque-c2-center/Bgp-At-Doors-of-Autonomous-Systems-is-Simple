$(call check_defined,ADDRESS MASK UTILS_DIR ROOT)

include $(ROOT)/$(UTILS_DIR)/utils.mk

TEMPLATE = ./entrypoint.sh.template
NAME = gns3_pc

$(shell $(call render_machine_template,$(TEMPLATE)))

build:
	docker build -t $(NAME) .

debug: build clean
	docker create --rm -it \
	--name $(NAME)  \
	-p $(PORT):22 \
	--entrypoint "/debug.sh" \
	$(NAME):latest
	docker cp ./debug.sh $(NAME):/debug.sh
	docker start $(NAME)

clean:
	docker container rm -f $(NAME)

.PHONY: build debug clean
