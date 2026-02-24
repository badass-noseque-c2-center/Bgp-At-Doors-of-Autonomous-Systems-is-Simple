build:
	docker build -t $(NAME) .

debug: build clean
	docker create --rm -it \
	--name $(NAME)  \
	--hostname $(NAME)  \
	-p $(PORT):22 \
	--entrypoint "/debug.sh" \
	$(NAME):latest
	docker start $(NAME)

clean:
	docker container rm -f $(NAME)
