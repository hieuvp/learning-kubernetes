#!/usr/bin/env bash
set -x pipefail

# Anonymous call of the API Server without authentication
curl https://kubernetes/api/v1 --insecure

# Retrieve the token of the "default" ServiceAccount
# Remember the volume/volumeMounts instructions above
TOKEN=$(cat /run/secrets/kubernetes.io/serviceaccount/token)

# Using the ServiceAccount token to authenticate against the API Server
curl https://kubernetes/api/v1 --insecure \
  --header "Authorization: Bearer ${TOKEN}"

# Let's now try something more ambitious,
# use this token to list all the Pods within the default namespace
curl https://kubernetes/api/v1/namespaces/default/pods --insecure \
  --header "Authorization: Bearer ${TOKEN}"
