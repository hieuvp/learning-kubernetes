#!/usr/bin/env bash
set -eoux pipefail

kubectl delete --filename labs/default-pod.yaml || true

kubectl apply --filename labs/default-pod.yaml

sleep 10

kubectl cp labs/default-test.sh default-pod:/root/test.sh
kubectl exec -it default-pod -- chmod +x /root/test.sh

kubectl exec -it default-pod -- ls -lia /root
