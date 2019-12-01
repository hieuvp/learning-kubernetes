#!/usr/bin/env bash
set -x pipefail

helm list

helm install stable/dokuwiki --namespace=test
kubectl get pods --namespace=test --watch

helm list

helm install stable/dokuwiki
kubectl run --image=bitnami/dokuwiki dokuwiki
kubectl get pods

helm list

helm install stable/dokuwiki --namespace=kube-system

helm list
