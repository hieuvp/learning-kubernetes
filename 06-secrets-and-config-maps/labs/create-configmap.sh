#!/usr/bin/env bash
# Run a command through "/usr/bin/env" has a benefit of
# looking for whatever the default version of the program is in your current environment

# $ /usr/bin/env bash
# Output: bash-5.0

# $ /bin/bash
# Output: bash-3.2

# Fail fast and be aware of exit codes
# @see: https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail
set -eoux pipefail
# -e: any command returning a non-zero exit code will cause an immediate exit
# -o: set the exit code of a pipeline (which is a sequence of commands separated by "|" or "|&")
#     to the rightmost command that exits with a non-zero status,
#     or to zero if all commands of the pipeline exit successfully
# -u: cause the bash shell to treat unset variables as an error and exit immediately
# -x: cause bash to print each command before executing it,
#     great help when debugging a bash script failure

kubectl create configmap mariadb-config --from-file=labs/max_allowed_packet.cnf
