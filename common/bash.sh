#!/bin/bash

# Open an interactive shell inside a build sandbox (rootless).

# go to root dir
cd "$(dirname $0)/.."

source "common/env.sh"

run_in_sandbox --chdir /root /bin/bash --login "$@"
