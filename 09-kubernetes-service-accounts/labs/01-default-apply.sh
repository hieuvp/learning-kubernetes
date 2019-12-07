#!/usr/bin/env bash
set -eoux pipefail

# Treat "resource not found" as a successful delete
# Immediately remove resources and bypass graceful deletion
kubectl delete --filename labs/01-default-pod.yaml \
  --ignore-not-found \
  --grace-period=0 --force

kubectl apply --filename labs/01-default-pod.yaml

sleep 10

kubectl cp labs/01-default-test.sh default-pod:/root/test.sh
kubectl exec -it default-pod -- chmod +x /root/test.sh
