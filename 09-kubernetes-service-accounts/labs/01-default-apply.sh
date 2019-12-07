#!/usr/bin/env bash
set -eoux pipefail

# Treat "resource not found" as a successful delete
# Immediately remove resources and bypass graceful deletion
kubectl delete --filename labs/01-default-pod.yaml \
  --ignore-not-found \
  --grace-period=0 --force

kubectl apply --filename labs/01-default-pod.yaml

sleep 5

declare -r POD="default-pod"
kubectl cp labs/01-default-test.sh ${POD}:/root/test.sh
kubectl exec -it ${POD} -- chmod +x /root/test.sh
