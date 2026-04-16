build: bridge
	docker build -t $(NAME) .

# This machines will need network capabilites. But since it is running inside a VM
# for simplicity --privileged is used.
debug: build clean bridge
	docker run --rm -d \
	--env-file ./$(subst $(suffix $(TEMPLATE)),,$(TEMPLATE)) \
	--privileged \
	--sysctl net.ipv4.ip_forward=1 \
	--name $(NAME)  \
	--hostname $(NAME)  \
	-p $(SSH_PORT):$(SSH_PORT) \
	$(NAME):latest

clean:
	docker container rm -f $(NAME)

bridge:
	$(call bridge_connection,$(ADDRESS),$(BRIDGE_PORT),$(SSH_PORT))
