#!/usr/bin/env bash
set -x pipefail

# Print the version information
kubectl version --short
helm version --short

# Read kubeconfig file
cat ~/.kube/config

kubectl config get-clusters
kubectl config get-contexts
kubectl config current-context
kubectl get pods
