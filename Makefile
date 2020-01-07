# Automatically format YAML files
# Check for syntax validity, weirdnesses and cosmetic problems
.PHONY: lint
lint:
	cd 05-helm/labs/01-without-helm && prettier --write *.yaml && yamllint --strict .
	scripts/lint-helm.sh 05-helm/labs/02-developing-templates
	cd 06-secrets-and-config-maps/labs && prettier --write *.yaml && yamllint --strict .
	cd 07-kubernetes-persistent-volumes/labs && prettier --write *.yaml && yamllint --strict .

# Generate table of contents
# Keep docs up-to-date from local or remote sources
.PHONY: docs
docs:
	scripts/format-readme.sh .
	scripts/format-readme.sh 01-minikube
	scripts/format-readme.sh 02-kubectl
	scripts/format-readme.sh 03-kubernetes-architecture
	scripts/format-readme.sh 04-kubernetes-objects

	cd 05-helm/labs/02-developing-templates && make render
	scripts/format-readme.sh 05-helm

	scripts/format-readme.sh 06-secrets-and-config-maps
	scripts/format-readme.sh 07-kubernetes-persistent-volumes

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
