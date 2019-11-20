#!/usr/bin/env bash
set -eoux pipefail

kubectl apply --filename labs/02-setting-rbac-rules/01-pod-access-role.yaml
kubectl apply --filename labs/02-setting-rbac-rules/02-ns-admin-role.yaml

kubectl apply --filename labs/02-setting-rbac-rules/03-devs-read-pods.yaml
kubectl apply --filename labs/02-setting-rbac-rules/04-harrison-ns-admin.yaml

kubectl apply --filename labs/02-setting-rbac-rules/05-all-pods-access.yaml
kubectl apply --filename labs/02-setting-rbac-rules/06-harrison-reads-all-pods.yaml
