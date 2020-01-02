#!/usr/bin/env bash

args=("$@")
set -eoux pipefail

declare -r FILENAME=README.md
declare -r DIRECTORY=${args[0]}

cd "${DIRECTORY}"
doctoc "${FILENAME}"
md-magic "${FILENAME}"
prettier --write "${FILENAME}"
