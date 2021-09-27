# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Standard
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.PHONY: fmt
fmt:
	@printf "\n"
	$(MAKEFILE_SCRIPT_PATH)/fmt-shell.sh
	$(MAKEFILE_SCRIPT_PATH)/fmt-yaml.sh
	$(MAKEFILE_SCRIPT_PATH)/fmt-markdown.sh
	@printf "\n"

.PHONY: lint
lint:
	@printf "\n"
	$(MAKEFILE_SCRIPT_PATH)/lint-shell.sh
	$(MAKEFILE_SCRIPT_PATH)/lint-yaml.sh
	@printf "\n"

.PHONY: git-add
git-add: fmt lint
	@printf "\n"
	git add --all .
	@printf "\n"


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Minikube
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Start the minikube Kubernetes cluster
.PHONY: minikube-start
minikube-start:
	minikube start --vm-driver=virtualbox
	minikube addons enable ingress
	minikube ip

# Delete the minikube Kubernetes cluster
.PHONY: minikube-delete
minikube-delete:
	minikube stop
	minikube delete
	minikube cache delete
	killall VBoxHeadless VBoxSVC VBoxNetDHCP || true
	rm -rf ~/Library/VirtualBox/HostInterfaceNetworking-vboxnet0-Dhcpd.*
