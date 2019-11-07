#!/usr/bin/env bash
set -eoux pipefail

# generic: create a secret from a local file, directory or literal value
# docker-registry: create a secret for use with a Docker registry
# tls: create a TLS secret
kubectl create secret generic mariadb-user-creds \
  --from-literal=MYSQL_USER=kubeuser \
  --from-literal=MYSQL_PASSWORD=kube-still-rocks
