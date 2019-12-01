#!/usr/bin/env bash
set -eoux pipefail

declare -r MINIKUBE_IP="192.168.99.100"
declare -r MINIKUBE_PORT="8443"

declare -r CLUSTER_NAME="minikube"

declare -r CERTIFICATE_DIR=".certificates"
declare -r CERTIFICATE_USER="harrison"

######################################################
# Add into your local machine the new configuration
######################################################

# Add the new cluster to kubectl
kubectl config set-cluster ${CLUSTER_NAME} \
  --certificate-authority=${CERTIFICATE_DIR}/ca.crt \
  --embed-certs=true \
  --server=https://${MINIKUBE_IP}:${MINIKUBE_PORT}

# Add the new credentials to kubectl
kubectl config set-credentials ${CERTIFICATE_USER}@${CLUSTER_NAME} \
  --client-certificate=${CERTIFICATE_DIR}/${CERTIFICATE_USER}.crt \
  --client-key=${CERTIFICATE_DIR}/${CERTIFICATE_USER}.key \
  --embed-certs=true

# Add the new context to kubectl
kubectl config set-context ${CERTIFICATE_USER}@${CLUSTER_NAME} \
  --cluster=${CLUSTER_NAME} \
  --user=${CERTIFICATE_USER}@${CLUSTER_NAME}

# Change to the newly created context
kubectl config use-context ${CERTIFICATE_USER}@${CLUSTER_NAME}
