#!/usr/bin/env bash
set -x pipefail

cat .kube/config

kubectl version --short
helm version --short

kubectl config get-clusters
kubectl config get-contexts

kubectl get pods