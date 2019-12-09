#!/usr/bin/env bash
set -x pipefail

helm reset --force --tiller-connection-timeout=10
helm init --service-account=tiller-sa

sleep 5

helm list
helm version --short
