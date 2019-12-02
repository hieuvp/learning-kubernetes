#!/usr/bin/env bash
set -eoux pipefail

kubectl apply --filename labs/demo-sa.yaml
kubectl apply --filename labs/pod-access-role.yaml
kubectl apply --filename labs/demo-reads-pods.yaml
kubectl apply --filename labs/demo-pod.yaml
