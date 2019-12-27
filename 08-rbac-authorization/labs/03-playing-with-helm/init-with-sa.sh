#!/usr/bin/env bash
set -x pipefail

helm reset --remove-helm-home --tiller-connection-timeout=5 --force
helm init --service-account=tiller-sa

sleep 15

helm version --short
helm list
