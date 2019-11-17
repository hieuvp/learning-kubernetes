NAME := rbac

up:
	docker-compose up --build --detach

down:
	docker-compose down --rmi=all

check:
	docker exec -it --user root ${NAME} kubectl version --short
	docker exec -it --user root ${NAME} helm version --client --short

	docker exec -it --user root ${NAME} kubectl config get-clusters
	docker exec -it --user root ${NAME} kubectl config get-contexts
	docker exec -it --user root ${NAME} kubectl get pods || true

.PHONY: up down check
