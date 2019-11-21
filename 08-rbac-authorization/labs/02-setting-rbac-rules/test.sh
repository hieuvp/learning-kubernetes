#!/usr/bin/env bash
set -eoux pipefail

kubectl get pods
kubectl get pods --namespace=test
kubectl get pods --namespace=test --watch
kubectl get pods --namespace=kube-system

kubectl run nginx --image=nginx --replicas=2
kubectl run nginx --namespace=test --image=nginx --replicas=2
kubectl expose deployment nginx --namespace=test --type=NodePort --port=80

kubectl get services
kubectl get services --namespace=test
