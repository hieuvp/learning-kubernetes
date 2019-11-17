#!/usr/bin/env bash
set -eoux pipefail

# MySQL - Hollow Database
kubectl apply --filename labs/mysql-pv.yaml
kubectl apply --filename labs/mysql-pvc.yaml
kubectl apply --filename labs/mysql-deployment.yaml
kubectl apply --filename labs/mysql-service.yaml

# Hollow App
kubectl apply --filename labs/hollow-config.yaml
kubectl apply --filename labs/hollow-deployment.yaml
kubectl apply --filename labs/hollow-service.yaml
kubectl apply --filename labs/hollow-ingress.yaml
