#!/usr/bin/env bash
set -eoux pipefail

kubectl delete --filename labs/02-demo-sa.yaml || true
kubectl delete --filename labs/02-pod-access-role.yaml || true
kubectl delete --filename labs/02-demo-reads-pods.yaml || true
kubectl delete --filename labs/02-demo-pod.yaml || true

kubectl apply --filename labs/02-demo-sa.yaml
kubectl apply --filename labs/02-pod-access-role.yaml
kubectl apply --filename labs/02-demo-reads-pods.yaml
kubectl apply --filename labs/02-demo-pod.yaml
