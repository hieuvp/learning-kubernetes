#!/usr/bin/env bash
set -eoux pipefail

kubectl apply --filename labs/demo-serviceaccount.yaml
kubectl apply --filename labs/list-pods.yaml
kubectl apply --filename labs/list-pods-demo-sa.yaml
kubectl apply --filename labs/pod-demo-sa.yaml
