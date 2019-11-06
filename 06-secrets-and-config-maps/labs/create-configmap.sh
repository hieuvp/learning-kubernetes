#!/usr/bin/env bash
# Running a command through "/usr/bin/env" has the benefit of
# looking for whatever the default version of the program is in your current environment

# $ /usr/bin/env bash
# Output: bash-5.0

# $ /bin/bash
# Output: bash-3.2

# Fail fast and be aware of exit codes
# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail
set -euxo pipefail
# -e: cause a bash script to exit immediately when a command fails
# Any command returning a non-zero exit code will cause an immediate exit
# - o: sets the exit code of a pipeline to that of the rightmost command to exit with a non-zero status,
# or to zero if all commands of the pipeline exit successfully
# -u: causes the bash shell to treat unset variables as an error and exit immediately
# -x: causes bash to print each command before executing it
# great help when trying to debug a bash script failure

kubectl create configmap mariadb-config --from-file=labs/max_allowed_packet.cnf
