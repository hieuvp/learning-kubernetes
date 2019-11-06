#!/usr/bin/env bash
# Why?

# Fail fast and be aware of exit codes
# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail
set -euxo pipefail

kubectl create configmap mariadb-config --from-file=labs/max_allowed_packet.cnf
