# Generate table of contents
# Keep docs up-to-date from local or remote sources
docs:
	cd 01-minikube && doctoc README.md && md-magic README.md
	cd 02-kubectl && doctoc README.md && md-magic README.md
	cd 03-kubernetes-architecture && doctoc README.md && md-magic README.md
	cd 04-kubernetes-objects && doctoc README.md && md-magic README.md
	cd 05-helm && doctoc README.md && md-magic README.md

# Reset the minikube kubernetes cluster
reset:
	minikube delete
	minikube start --vm-driver=virtualbox
	minikube ip

# Makefile will get confused if there are files and folders with the names of recipes
# Unless we mark them as 'PHONY'
# @see http://www.gnu.org/software/make/manual/make.html#Phony-Targets
.PHONY: docs reset
