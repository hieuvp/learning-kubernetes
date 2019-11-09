#!/usr/bin/env bash
set -eoux pipefail

kubectl apply --filename labs/01-without-helm/frontend.yaml
kubectl apply --filename labs/01-without-helm/frontend-config.yaml
kubectl apply --filename labs/01-without-helm/frontend-service.yaml
kubectl apply --filename labs/01-without-helm/ingress.yaml

kubectl apply --filename labs/01-without-helm/backend.yaml
kubectl apply --filename labs/01-without-helm/backend-secret.yaml
kubectl apply --filename labs/01-without-helm/backend-service.yaml

kubectl apply --filename labs/01-without-helm/mongodb.yaml
kubectl apply --filename labs/01-without-helm/mongodb-pv.yaml
kubectl apply --filename labs/01-without-helm/mongodb-pvc.yaml
kubectl apply --filename labs/01-without-helm/mongodb-secret.yaml
kubectl apply --filename labs/01-without-helm/mongodb-service.yaml
