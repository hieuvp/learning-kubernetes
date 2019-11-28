#!/usr/bin/env bash
set -eoux pipefail

declare -r MINIKUBE_IP="192.168.99.100"
declare -r CERTIFICATE_DIR=".certificates"
declare -r CERTIFICATE_USER="harrison"

######################################################
# Add into your local machine the new configuration
######################################################

# Add the new cluster to kubectl
kubectl config set-cluster minikube \
  --certificate-authority=${CERTIFICATE_DIR}/ca.crt \
  --embed-certs=true \
  --server=https://${MINIKUBE_IP}:8443

# Add the new credentials to kubectl
kubectl config set-credentials ${CERTIFICATE_USER}@minikube \
  --client-certificate=${CERTIFICATE_DIR}/${CERTIFICATE_USER}.crt \
  --client-key=${CERTIFICATE_DIR}/${CERTIFICATE_USER}.key \
  --embed-certs=true

# Add the new context to kubectl
kubectl config set-context ${CERTIFICATE_USER}@minikube \
  --cluster=minikube \
  --user=${CERTIFICATE_USER}@minikube

# Change to the newly created context
kubectl config use-context ${CERTIFICATE_USER}@minikube
