#!/usr/bin/env bash
set -eoux pipefail

kubectl delete --filename labs/default-pod.yaml --grace-period=1 || true

kubectl apply --filename labs/default-pod.yaml
sleep 5

kubectl cp labs/default-test.sh default-pod:/root/test.sh
kubectl exec -it default-pod -- chmod +x /root/test.sh

kubectl exec -it default-pod -- ls -lia /root
