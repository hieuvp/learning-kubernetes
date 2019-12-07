#!/usr/bin/env bash
set -x pipefail

# Anonymously call of the API Server
# Get information from the API Server without authentication
curl https://kubernetes/api/v1 --insecure

# Call using the ServiceAccount token
TOKEN=$(cat /run/secrets/kubernetes.io/serviceaccount/token)
curl https://kubernetes/api/v1 --insecure \
  --header "Authorization: Bearer ${TOKEN}"
