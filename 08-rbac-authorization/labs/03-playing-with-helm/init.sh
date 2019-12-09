#!/usr/bin/env bash
set -x pipefail

helm reset --force --tiller-connection-timeout=10
helm init

sleep 15

helm list
helm version --short
