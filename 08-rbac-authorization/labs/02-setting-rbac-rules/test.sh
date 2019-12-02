#!/usr/bin/env bash
set -x pipefail

kubectl get pods
kubectl get pods --namespace=test
kubectl get pods --namespace=kube-system

timeout 3s kubectl get pods --watch --namespace=test

kubectl run nginx --generator=run-pod/v1 --image=nginx --replicas=2
kubectl run nginx --generator=run-pod/v1 --image=nginx --replicas=2 --namespace=test

kubectl expose deployment nginx --type=NodePort --port=80 --namespace=test

kubectl get services
kubectl get services --namespace=test
