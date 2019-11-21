up:
	docker-compose up --build --detach
	rm -rf .certificates/

down:
	docker-compose down --rmi=all
	docker system prune --force
	rm -rf .certificates/

.PHONY: up down
