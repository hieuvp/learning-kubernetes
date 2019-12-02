#!/usr/bin/env bash
set -x pipefail

kubectl get pods --namespace=test
kubectl get pods --namespace=kube-system
kubectl get pods

timeout 3s kubectl get pods --watch --namespace=test

kubectl run nginx --generator=run-pod/v1 --image=nginx --replicas=2 --namespace=test
kubectl run nginx --generator=run-pod/v1 --image=nginx --replicas=2

kubectl expose pod nginx --type=NodePort --port=80 --namespace=test

kubectl get services --namespace=test
kubectl get services
