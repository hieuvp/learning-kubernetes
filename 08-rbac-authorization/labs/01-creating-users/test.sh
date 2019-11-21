#!/usr/bin/env bash
set -eoux pipefail

cat .kube/config

kubectl version --short
helm version --client --short

kubectl config get-clusters
kubectl config get-contexts

kubectl get pods
