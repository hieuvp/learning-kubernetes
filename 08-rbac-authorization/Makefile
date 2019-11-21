up:
	labs/01-creating-users/create-certificates.sh
	docker-compose up --build --detach

down:
	docker-compose down --rmi=all
	docker system prune --force
	rm -rf .certificates/

.PHONY: up down
