# Create and start a machine simulation
up:
	docker-compose up --build --detach
	rm -rf .certificates/

# Stop and remove the machine simulation
down:
	docker-compose down --rmi=all
	docker system prune --force
	rm -rf .certificates/

.PHONY: up down
