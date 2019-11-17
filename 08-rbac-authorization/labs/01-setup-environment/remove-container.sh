#!/usr/bin/env bash
set -eoux pipefail

declare -r NAME="rbac"

docker stop ${NAME}
docker rm ${NAME}
docker rmi ${NAME}

sleep 5
docker images --all
docker ps --all
