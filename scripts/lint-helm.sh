#!/usr/bin/env bash

args=("$@")
set -eoux pipefail

declare -r DIRECTORY=${args[0]}

cd "${DIRECTORY}"
prettier --write ./*.yaml
yamllint --strict ./*.yaml
helm lint

# Validate output
#cd  && prettier --write *.yaml
#	cd 05-helm/labs/02-developing-templates && yamllint --strict *.yaml
#	cd 05-helm/labs/02-developing-templates && helm lint
