#!/usr/bin/env bash
# Why?

set -o pipefail
# Why?

kubectl create secret generic mariadb-user-creds \
  --from-literal=MYSQL_USER=kubeuser \
  --from-literal=MYSQL_PASSWORD=kube-still-rocks

# secret/mariadb-user-creds created
