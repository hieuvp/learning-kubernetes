#!/usr/bin/env bash
set -x pipefail

helm reset --remove-helm-home --tiller-connection-timeout=5 --force
helm init

sleep 15

helm version --short
helm list
