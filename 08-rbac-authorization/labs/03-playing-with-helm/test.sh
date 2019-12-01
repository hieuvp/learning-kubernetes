#!/usr/bin/env bash
set -x pipefail

# Try deploying a dokuwiki chart
helm list
helm install stable/dokuwiki --namespace=test
kubectl get pods --namespace=test --watch

helm install stable/dokuwiki
kubectl run --image=bitnami/dokuwiki dokuwiki
kubectl get pods

helm install stable/dokuwiki --namespace=kube-system

# Let's try now
helm list
helm install stable/dokuwiki

# Let's check if Tiller works now
helm list
