#!/usr/bin/env bash

args=("$@")
set -eoux pipefail

declare -r INPUT_DIR=templates
declare -r OUTPUT_DIR=${args[0]}
mapfile -t TEMPLATES < <(find ${INPUT_DIR} -name '*.yaml' | sed "s/${INPUT_DIR}\///")

for filename in "${TEMPLATES[@]}"; do
  helm template . --show-only="${INPUT_DIR}/${filename}" >"${OUTPUT_DIR}/${filename}"
done
