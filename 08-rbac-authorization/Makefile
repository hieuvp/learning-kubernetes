# Create and start a simulation machine
up:
	docker-compose up --build --detach
	rm -rf .certificates/

# Stop and remove the simulation machine
down:
	docker-compose down --rmi=all
	docker system prune --force
	rm -rf .certificates/

.PHONY: up down
