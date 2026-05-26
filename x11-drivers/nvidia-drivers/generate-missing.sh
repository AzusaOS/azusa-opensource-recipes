#!/bin/sh
# Generate nvidia-drivers-<version>.sh files for versions available upstream
# that are not yet present in this directory.
#
# Logic:
#   - Fetch the list of versions from the redist URL (preferred source)
#   - Fetch the list of versions from the XFree86 URL (fallback source)
#   - For each version not already present locally:
#       - If available in redist, generate a file calling nvidia_process_redist
#       - Otherwise, generate a file calling nvidia_process_xfree86
#   - By default only versions >= MIN_VERSION are considered, to avoid
#     creating files for very old XFree86-only releases. Override via env:
#       MIN_VERSION=0 ./generate-missing.sh   # generate for all versions
#
# Run with --dry-run to only print what would be created.

set -eu

cd "$(dirname "$0")"

REDIST_URL="https://developer.download.nvidia.com/compute/nvidia-driver/redist/nvidia_driver/linux-x86_64/"
XFREE86_URL="https://download.nvidia.com/XFree86/Linux-x86_64/"
MIN_VERSION="${MIN_VERSION:-390}"

DRY_RUN=0
for arg in "$@"; do
	case "$arg" in
		-n|--dry-run) DRY_RUN=1 ;;
		-h|--help)
			sed -n '2,/^$/p' "$0" | sed 's/^# \{0,1\}//'
			exit 0
			;;
		*)
			echo "Unknown argument: $arg" >&2
			exit 1
			;;
	esac
done

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "Fetching redist version list..." >&2
curl -fsSL "$REDIST_URL" \
	| grep -oE 'nvidia_driver-linux-x86_64-[0-9.]+-archive\.tar\.xz' \
	| sed -E 's/nvidia_driver-linux-x86_64-(.+)-archive\.tar\.xz/\1/' \
	| sort -u >"$tmp/redist"

echo "Fetching XFree86 version list..." >&2
curl -fsSL "$XFREE86_URL" \
	| grep -oE "href='[0-9][^']*/'" \
	| sed -E "s/href='([^']+)\/'/\1/" \
	| sort -u >"$tmp/xfree86"

# Filter by major version (first numeric component before the first dot)
filter_min() {
	awk -F. -v min="$MIN_VERSION" '$1+0 >= min+0 {print}'
}

filter_min <"$tmp/redist" >"$tmp/redist.f"
filter_min <"$tmp/xfree86" >"$tmp/xfree86.f"

# Union of both, deduplicated
sort -u "$tmp/redist.f" "$tmp/xfree86.f" >"$tmp/all"

write_file() {
	local version="$1"
	local mode="$2"
	local path="nvidia-drivers-${version}.sh"
	if [ "$DRY_RUN" -eq 1 ]; then
		printf '  would create %s (%s)\n' "$path" "$mode"
		return
	fi
	cat >"$path" <<EOF
#!/bin/sh
source "../../common/init.sh"
source "\$BASEDIR/nvidia-drivers.sh"

nvidia_process_${mode}
EOF
	chmod +x "$path"
	printf '  created %s (%s)\n' "$path" "$mode"
	./"$path" || rm -f "$path"
}

created=0
while IFS= read -r version; do
	[ -n "$version" ] || continue
	file="nvidia-drivers-${version}.sh"
	if [ -e "$file" ]; then
		continue
	fi
	if grep -qx "$version" "$tmp/redist.f"; then
		write_file "$version" redist
	else
		write_file "$version" xfree86
	fi
	created=$((created + 1))
done <"$tmp/all"

if [ "$created" -eq 0 ]; then
	echo "No missing versions." >&2
else
	echo "$created version(s) processed." >&2
fi
