#!/usr/bin/env bash
set -eoux pipefail

args=("$@")
declare -r FILENAME=README.md
declare -r DIRECTORY=${args[0]}

cd "${DIRECTORY}"
doctoc "${FILENAME}"
md-magic "${FILENAME}"
prettier --write "${FILENAME}"
