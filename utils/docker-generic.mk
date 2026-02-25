build:
	docker build -t $(NAME) .

debug: build clean
	docker run --rm -d \
	--name $(NAME)  \
	--hostname $(NAME)  \
	-p $(PORT):22 \
	--entrypoint "/debug.sh" \
	$(NAME):latest

clean:
	docker container rm -f $(NAME)
