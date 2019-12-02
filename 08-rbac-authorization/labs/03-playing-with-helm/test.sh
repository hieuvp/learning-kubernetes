#!/usr/bin/env bash
set -x pipefail

helm version --short

# Namespace "test"
helm install stable/dokuwiki --namespace=test
helm list
timeout 5s kubectl get pods --namespace=test --watch

# Namespace "default"
helm install stable/dokuwiki
helm list
kubectl run dokuwiki --generator=run-pod/v1 --image=bitnami/dokuwiki
kubectl get pods

# Namespace "kube-system"
helm install stable/dokuwiki --namespace=kube-system
helm list
