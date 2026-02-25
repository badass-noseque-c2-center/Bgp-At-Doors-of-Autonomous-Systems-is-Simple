build:
	docker build -t $(NAME) .

# This machines will need network capabilites. But since it is running inside a VM
# for simplicity --privileged is used.
debug: build clean
	docker run --rm -d \
	--privileged \
	--name $(NAME)  \
	--hostname $(NAME)  \
	-p $(PORT):22 \
	--entrypoint "/debug.sh" \
	$(NAME):latest

clean:
	docker container rm -f $(NAME)
