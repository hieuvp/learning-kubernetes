# Create and start a machine simulation
up:
	docker-compose up --build --detach
	rm -rf .certificates/

# Stop and remove the machine simulation
down:
	docker-compose down --rmi=all
	docker system prune --force
	rm -rf .certificates/

# Create and configure a user to access Kubernetes
config:
	labs/01-creating-users/01-create-certificate.sh
	docker exec -it --user=root rbac-authorization labs/01-creating-users/02-config-kubectl.sh

.PHONY: up down config
