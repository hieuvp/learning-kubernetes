#!/usr/bin/env bash
set -eoux pipefail

declare -r MINIKUBE_IP=192.168.99.100

# Add new kubectl context
kubectl config set-cluster minikube \
  --certificate-authority=.certificates/ca.crt \
  --embed-certs=true \
  --server=https://${MINIKUBE_IP}:8443

kubectl config set-credentials harrison@minikube \
  --client-certificate=.certificates/harrison.crt \
  --client-key=.certificates/harrison.key \
  --embed-certs=true

kubectl config set-context harrison@minikube \
  --cluster=minikube \
  --user=harrison@minikube

# Set new context
kubectl config use-context harrison@minikube
