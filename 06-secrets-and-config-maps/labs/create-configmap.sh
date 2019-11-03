#!/usr/bin/env bash
# Why?

set -o pipefail
# Why?

kubectl create configmap mariadb-config --from-file=labs/max_allowed_packet.cnf
