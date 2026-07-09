#!/bin/bash
# Prepare a rootless build sandbox.
#
# The actual namespace + mount setup (user/pid/mount namespaces, a writable
# overlay on /pkg/main, a fresh /dev and /proc) is performed by bubblewrap when
# run_in_sandbox launches a command. Because everything happens inside a user
# namespace this no longer requires root, and every mount is torn down
# automatically when the sandboxed process exits (nothing leaks into the host).

set -e

source "common/arch.sh"

BWRAP="/pkg/main/sys-apps.bubblewrap.core.linux.${ARCH}/bin/bwrap"
if [ ! -x "$BWRAP" ]; then
	echo "bubblewrap not found at $BWRAP"
	echo "Build it first: ./build.sh sys-apps/bubblewrap"
	exit 1
fi

# Rootless builds map the invoking user's subordinate uid/gid ranges into the
# sandbox (see run_in_sandbox), which is what lets the build chown files to
# arbitrary owners. Check the prerequisites up front so a misconfigured host
# fails here with a clear message instead of deep inside a build.
check_rootless_prereqs() {
	local user uid h f missing

	for h in newuidmap newgidmap; do
		if ! command -v "$h" >/dev/null 2>&1; then
			echo "ERROR: $h not found; rootless id mapping needs it (package: shadow)."
			exit 1
		fi
	done

	user="$(id -un)"
	uid="$(id -u)"
	for f in /etc/subuid /etc/subgid; do
		if [ ! -e "$f" ] || ! grep -qE "^($user|$uid):[0-9]+:[0-9]+" "$f"; then
			missing="$missing $f"
		fi
	done
	if [ -n "$missing" ]; then
		echo "ERROR: no subordinate uid/gid range for '$user' (missing/empty entry in:$missing)"
		echo
		echo "Rootless builds need a subuid/subgid range for your user. Configure it"
		echo "once (as root), then re-run the build:"
		echo "    usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $user"
		echo "  or append manually:"
		echo "    echo '$user:100000:65536' >> /etc/subuid"
		echo "    echo '$user:100000:65536' >> /etc/subgid"
		exit 1
	fi
}
check_rootless_prereqs

tmp_dir=$(mktemp -d -t azusa-XXXXXXXXXX)
chmod 0755 "$tmp_dir"

unset LC_ALL LANG TMPDIR
export LC_ALL=C.utf8

echo "Temporary environment is in $tmp_dir ARCH=$ARCH"

# build the base FHS tree (bin/lib symlinks into /pkg/main, /etc from
# baselayout, apkg binaries, ...). The /dev nodes it can only mknod as root are
# skipped here; bubblewrap's --dev provides them instead.
"/pkg/main/azusa.symlinks.core.linux.${ARCH}/azusa/makeroot.sh" "$tmp_dir"

# mountpoints filled in by bubblewrap at launch
mkdir -p "$tmp_dir/pkg/main" "$tmp_dir/build" "$tmp_dir/run" \
	"$tmp_dir/.pkg-main-rw" "$tmp_dir/.pkg-main-work"

# host directory that receives the built .squashfs packages
APKG_OUT="${APKG_OUT:-/tmp/apkg}"
mkdir -p "$APKG_OUT"

cleanuptmp() {
	echo "Cleaning up $tmp_dir"
	# The build may have created files owned by mapped subuids (e.g. source
	# extracted with its archived ownership), which the invoking user cannot
	# remove directly. Delete from inside a range-mapped user namespace, where
	# in-namespace root can unlink them; fall back to a plain rm otherwise.
	unshare --user --map-auto --map-root-user --setgroups allow \
		rm -fr "$tmp_dir" 2>/dev/null || rm -fr "$tmp_dir" 2>/dev/null || true
}
trap cleanuptmp EXIT

# run_in_sandbox <command...>
# Launch a command inside the build sandbox. Extra bwrap options (e.g. --chdir)
# may be passed before the command.
#
# The user namespace is created by unshare (not bwrap) with --map-auto, which
# maps the invoking user to in-namespace root (uid 0) *and* the /etc/subuid
# range to in-namespace uids 1..N. That range is what lets the build chown files
# to arbitrary owners (needed by some packages) - something bwrap's own
# --unshare-user, which only maps a single uid, cannot do. bwrap then reuses
# this namespace (no --unshare-user) to set up the overlay, /dev, /proc, etc.
#
# Because in-namespace root maps back to the invoking user, packages written to
# /tmp/apkg come back owned by that user, so no post-build chown is needed.
# Requires /etc/subuid + /etc/subgid entries for the invoking user.
run_in_sandbox() {
	unshare --user --map-auto --map-root-user --setgroups allow \
		"$BWRAP" \
		--unshare-pid --unshare-ipc --unshare-uts --die-with-parent \
		--bind "$tmp_dir" / \
		--overlay-src /pkg/main \
		--overlay "$tmp_dir/.pkg-main-rw" "$tmp_dir/.pkg-main-work" /pkg/main \
		--bind "$tmp_dir/.pkg-main-rw" /.pkg-main-rw \
		--dev /dev --proc /proc \
		--tmpfs /tmp --bind "$APKG_OUT" /tmp/apkg \
		"$@"
}
