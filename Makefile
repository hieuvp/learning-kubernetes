# Automatically format YAML files
# Check for syntax validity, weirdnesses and cosmetic problems
.PHONY: lint
lint:
	cd 05-helm/labs/01-without-helm && prettier --write *.yaml && yamllint --strict .
	cd 05-helm/labs/02-developing-templates && prettier --write *.yaml && yamllint --strict *.yaml
	cd 06-secrets-and-config-maps/labs && prettier --write *.yaml && yamllint --strict .
	cd 07-kubernetes-persistent-volumes/labs && prettier --write *.yaml && yamllint --strict .

# Generate table of contents
# Keep docs up-to-date from local or remote sources
.PHONY: docs
docs:
	cd 01-minikube && doctoc README.md && md-magic README.md
	cd 02-kubectl && doctoc README.md && md-magic README.md
	cd 03-kubernetes-architecture && doctoc README.md && md-magic README.md
	cd 04-kubernetes-objects && doctoc README.md && md-magic README.md

	cd 05-helm/labs/02-developing-templates && make template
	cd 05-helm && doctoc README.md && md-magic README.md

	cd 06-secrets-and-config-maps && doctoc README.md && md-magic README.md
	cd 07-kubernetes-persistent-volumes && doctoc README.md && md-magic README.md

# Start the minikube Kubernetes cluster
.PHONY: start
start:
	minikube start --vm-driver=virtualbox
	minikube addons enable ingress
	minikube ip

# Delete the minikube Kubernetes cluster
.PHONY: delete
delete:
	minikube stop
	minikube delete
	minikube cache delete
	killall VBoxHeadless VBoxSVC VBoxNetDHCP || true
	rm -rf ~/Library/VirtualBox/HostInterfaceNetworking-vboxnet0-Dhcpd.*
