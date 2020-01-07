#!/usr/bin/env bash

args=("$@")
set -eoux pipefail

declare -r FILENAME=README.md
declare -r DIRECTORY=${args[0]}

doctoc "${DIRECTORY}/${FILENAME}"
(cd "${DIRECTORY}" && md-magic "${FILENAME}")
prettier --write "${DIRECTORY}/${FILENAME}"
markdownlint --fix "${DIRECTORY}/${FILENAME}"
