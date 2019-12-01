#!/usr/bin/env bash
set -eoux pipefail

declare -r CLUSTER_NAME="minikube"
declare -r CLUSTER_IP="192.168.99.100"
declare -r CLUSTER_PORT="8443"

declare -r CERTIFICATE_DIR=".certificates"
declare -r CERTIFICATE_USER="harrison"

#####################################################
# Add into your local machine the new configuration
#####################################################

# Add the new cluster to kubectl
# Set a cluster entry in kubeconfig
kubectl config set-cluster ${CLUSTER_NAME} \
  --certificate-authority=${CERTIFICATE_DIR}/ca.crt \
  --embed-certs=true \
  --server=https://${CLUSTER_IP}:${CLUSTER_PORT}
# embed-certs for the cluster entry in kubeconfig

# Add the new credentials to kubectl
# Set a user entry in kubeconfig
kubectl config set-credentials ${CERTIFICATE_USER}@${CLUSTER_NAME} \
  --client-certificate=${CERTIFICATE_DIR}/${CERTIFICATE_USER}.crt \
  --client-key=${CERTIFICATE_DIR}/${CERTIFICATE_USER}.key \
  --embed-certs=true
# --embed-certs: Embed client cert/key for the user entry in kubeconfig

# Add the new context to kubectl
# Set a context entry in kubeconfig
kubectl config set-context ${CERTIFICATE_USER}@${CLUSTER_NAME} \
  --cluster=${CLUSTER_NAME} \
  --user=${CERTIFICATE_USER}@${CLUSTER_NAME}

# Change to the newly created context
# Set the current-context in a kubeconfig file
kubectl config use-context ${CERTIFICATE_USER}@${CLUSTER_NAME}
