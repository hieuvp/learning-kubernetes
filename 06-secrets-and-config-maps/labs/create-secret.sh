#!/usr/bin/env bash

set -euxo pipefail

kubectl create secret generic mariadb-user-creds \
  --from-literal=MYSQL_USER=kubeuser \
  --from-literal=MYSQL_PASSWORD=kube-still-rocks
