#!/usr/bin/env bash
set -eoux pipefail

# To add in your local machine the new configuration

declare -r MINIKUBE_IP=192.168.99.100

# Download the cluster authority and generated certificate

# Add new kubectl context

# Add the new cluster to kubectl
kubectl config set-cluster minikube \
  --certificate-authority=.certificates/ca.crt \
  --embed-certs=true \
  --server=https://${MINIKUBE_IP}:8443

# Add the new credentials to kubectl
kubectl config set-credentials harrison@minikube \
  --client-certificate=.certificates/harrison.crt \
  --client-key=.certificates/harrison.key \
  --embed-certs=true

# Add the new context to kubectl
kubectl config set-context harrison@minikube \
  --cluster=minikube \
  --user=harrison@minikube

# Change to the newly created context
kubectl config use-context harrison@minikube
