# Automatically format YAML files
# Check for syntax validity, weirdnesses and cosmetic problems
lint:
	cd 05-helm/labs && ls | xargs -L 1 -I@ prettier --write @/*.yaml
	cd 05-helm/labs && ls | xargs -L 1 yamllint --strict
	cd 06-secrets-and-config-maps/labs && prettier --write *.yaml && yamllint --strict .
	cd 07-kubernetes-persistent-volumes/labs && prettier --write *.yaml && yamllint --strict .

# Generate table of contents
# Keep docs up-to-date from local or remote sources
docs:
	cd 01-minikube && doctoc README.md && md-magic README.md
	cd 02-kubectl && doctoc README.md && md-magic README.md
	cd 03-kubernetes-architecture && doctoc README.md && md-magic README.md
	cd 04-kubernetes-objects && doctoc README.md && md-magic README.md
	cd 05-helm && doctoc README.md && md-magic README.md
	cd 06-secrets-and-config-maps && doctoc README.md && md-magic README.md
	cd 07-kubernetes-persistent-volumes && doctoc README.md && md-magic README.md

# Start the minikube Kubernetes cluster
start:
	minikube start --vm-driver=virtualbox
	minikube addons enable ingress
	minikube ip

# Delete the minikube Kubernetes cluster
delete:
	minikube stop
	minikube delete
	minikube cache delete
	killall VBoxHeadless VBoxSVC VBoxNetDHCP || true
	rm -rf ~/Library/VirtualBox/HostInterfaceNetworking-vboxnet0-Dhcpd.*

# Makefile will get confused if there are files and folders with the names of recipes
# Unless we mark them as 'PHONY'
# @see http://www.gnu.org/software/make/manual/make.html#Phony-Targets
.PHONY: lint docs start delete
