#!/usr/bin/env bash
set -eoux pipefail

kubectl apply --filename labs/03-playing-with-helm/01-helm-tiller-access.yaml
kubectl apply --filename labs/03-playing-with-helm/02-harrison-use-tiller.yaml
kubectl apply --filename labs/03-playing-with-helm/03-tiller-serviceaccount.yaml
kubectl apply --filename labs/03-playing-with-helm/04-tiller-clusterrolebinding.yaml
