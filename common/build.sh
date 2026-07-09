#!/bin/bash
set -e

# go to root dir
cd "$(dirname $0)/.."
AZUSA_RECIPES_ROOT=`pwd`

# Compile a given package ($1) inside a rootless bubblewrap sandbox
PKG="$1"

if [ -f "$PKG" ]; then
	PKG_DIR=`dirname "$PKG"`
	PKG_SCRIPT=`basename "$PKG"`
elif [ -d "$PKG" ]; then
	# try to locate script (latest version)
	PKG_DIR="$PKG"
	PKG_SCRIPT=""
	for foo in "$PKG_DIR"/*.sh; do
		if [ -f "$foo" ]; then
			PKG_SCRIPT="$foo"
		fi
	done
	PKG_SCRIPT=`basename "$PKG_SCRIPT"`
else
	echo "$PKG not found"
	exit 1
fi

echo "Preparing to build $PKG"

source "common/env.sh"

echo "Copying azusa-opensource-recipes ..."

rsync -a "$AZUSA_RECIPES_ROOT"/ "$tmp_dir/root/azusa-opensource-recipes/"

echo "Build..."

# packages are written straight to the host $APKG_OUT (bound at /tmp/apkg) and,
# thanks to the uid mapping, already owned by the invoking user - so there is no
# post-build move or chown to do.
run_in_sandbox --chdir "/root/azusa-opensource-recipes/${PKG_DIR}" \
	/bin/bash -c "dbus-uuidgen --ensure=/etc/machine-id 2>/dev/null || true; exec ./${PKG_SCRIPT}"
