build:
	docker build -t $(NAME) .

# This machines will need network capabilites. But since it is running inside a VM
# for simplicity --privileged is used.
debug: build clean
	docker run --rm -d \
	--cap-add=NET_ADMIN \
	--cap-add=NET_RAW \
	--sysctl net.ipv4.ip_forward=1 \
	--name $(NAME)  \
	--hostname $(NAME)  \
	-p $(PORT):22 \
	--entrypoint "/debug.sh" \
	$(NAME):latest

clean:
	docker container rm -f $(NAME)
