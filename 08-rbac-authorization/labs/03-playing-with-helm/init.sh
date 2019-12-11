#!/usr/bin/env bash
set -x pipefail

helm reset --force --tiller-connection-timeout=5
helm init

sleep 15

helm version --short
helm list