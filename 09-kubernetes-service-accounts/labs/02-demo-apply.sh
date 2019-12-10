#!/usr/bin/env bash
set -eoux pipefail

kubectl delete --filename labs/02-demo-sa.yaml --ignore-not-found --grace-period=0 --force
kubectl delete --filename labs/02-pod-access-role.yaml --ignore-not-found --grace-period=0 --force
kubectl delete --filename labs/02-demo-reads-pods.yaml --ignore-not-found --grace-period=0 --force
kubectl delete --filename labs/02-demo-pod.yaml --ignore-not-found --grace-period=0 --force

kubectl apply --filename labs/02-demo-sa.yaml
kubectl apply --filename labs/02-pod-access-role.yaml
kubectl apply --filename labs/02-demo-reads-pods.yaml
kubectl apply --filename labs/02-demo-pod.yaml

sleep 10

declare -r POD="demo-pod"
kubectl cp labs/02-demo-test.sh ${POD}:/root/test.sh
kubectl exec -it ${POD} -- chmod +x /root/test.sh
