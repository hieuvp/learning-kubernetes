#!/usr/bin/env bash
set -eoux pipefail

declare -r NAME="rbac"

docker build --tag $NAME labs/01-setup-environment
docker run --detach --name=$NAME $NAME

sleep 5
docker images --all
docker ps --all
