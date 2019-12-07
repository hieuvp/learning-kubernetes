#!/usr/bin/env bash
set -x pipefail

# Anonymous call of the API Server without authentication
curl https://kubernetes/api/v1 --insecure

# Using the ServiceAccount token
TOKEN=$(cat /run/secrets/kubernetes.io/serviceaccount/token)
curl https://kubernetes/api/v1 --insecure \
  --header "Authorization: Bearer ${TOKEN}"
