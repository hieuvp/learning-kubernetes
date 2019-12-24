#!/usr/bin/env bash
set -x pipefail

# Get the ServiceAccount token from within the Pod's container
TOKEN=$(cat /run/secrets/kubernetes.io/serviceaccount/token)

# Call an API Server's endpoint (using the ClusterIP kubernetes service)
# to get all the Pods running in the default namespace
curl https://kubernetes/api/v1/namespaces/default/pods --insecure \
  --header "Authorization: Bearer ${TOKEN}"
