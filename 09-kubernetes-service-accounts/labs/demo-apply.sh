#!/usr/bin/env bash
set -eoux pipefail

kubectl delete --filename labs/demo-sa.yaml || true
kubectl delete --filename labs/pod-access-role.yaml || true
kubectl delete --filename labs/demo-reads-pods.yaml || true
kubectl delete --filename labs/demo-pod.yaml || true

kubectl apply --filename labs/demo-sa.yaml
kubectl apply --filename labs/pod-access-role.yaml
kubectl apply --filename labs/demo-reads-pods.yaml
kubectl apply --filename labs/demo-pod.yaml
