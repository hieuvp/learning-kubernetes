# Automatically format YAML files
# Check for syntax validity, weirdnesses and cosmetic problems
lint:
<<<<<<< HEAD
	cd 07-kubernetes-persistent-volumes/labs && prettier --write *.yaml && yamllint --strict .
=======
	cd 06-secrets-and-config-maps/labs && prettier --write *.yaml && yamllint --strict .
>>>>>>> master

# Generate table of contents
# Keep docs up-to-date from local or remote sources
docs:
	cd 01-minikube && doctoc README.md && md-magic README.md
	cd 02-kubectl && doctoc README.md && md-magic README.md
	cd 03-kubernetes-architecture && doctoc README.md && md-magic README.md
	cd 04-kubernetes-objects && doctoc README.md && md-magic README.md
	cd 05-helm && doctoc README.md && md-magic README.md
<<<<<<< HEAD
	cd 07-kubernetes-persistent-volumes && doctoc README.md && md-magic README.md

# Reset the minikube Kubernetes cluster
reset:
	minikube stop
	minikube delete
	minikube cache delete
	minikube start --vm-driver=virtualbox
	minikube addons enable ingress
	minikube ip
=======
	cd 06-secrets-and-config-maps && doctoc README.md && md-magic README.md

# Reset the minikube Kubernetes cluster
reset:
	minikube stop && minikube delete
	minikube cache delete
	minikube start --vm-driver=virtualbox --apiserver-ips=192.168.99.115
	minikube ssh sudo ifconfig eth1 192.168.99.115
	minikube update-context
	minikube ip
	minikube addons enable ingress
>>>>>>> master

# Makefile will get confused if there are files and folders with the names of recipes
# Unless we mark them as 'PHONY'
# @see http://www.gnu.org/software/make/manual/make.html#Phony-Targets
.PHONY: lint docs reset
