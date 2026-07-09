#!/bin/sh
cd "$(dirname $0)"

# Builds run in a rootless bubblewrap sandbox (see common/build.sh); no root or
# sudo is required.
exec ./common/build.sh "$@"
