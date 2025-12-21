#!/bin/bash

fetchgit() {
	# fetchgit repository tag
	local gitbase
	gitbase="$(basename $1)"
	gitbase="${gitbase/.git}"
	local tag
	tag="$2"
	local BN
	BN="${gitbase}-${tag}.tar.xz"

	# try to get from our system
	wget --ca-certificate=/etc/ssl/certs/ca-certificates.crt -O "$BN" "$(echo "https://pkg.azusa.jp/src/main/${CATEGORY}/${PN}/${BN}" | sed -e 's/+/%2B/g')" || true
	if [ -s "$BN" ]; then
		extract "$BN"
		# owner might differ, add directory to safe.directory
		git config --global --add safe.directory "${S}"
		return
	fi

	# failed download, get file, then upload...
	echo "Downloading from git: $1"
	git clone --no-checkout --quiet "$1" "${gitbase}-${tag}"
	cd "${gitbase}-${tag}"
	S="${PWD}"
	echo "Checking out tag $tag ..."
	git checkout --quiet --detach "$tag"
	git submodule update --recursive --init
	cd ..

	if [ -f "$HOME/.aws/credentials" ]; then
		echo "Archiving for upload..."
		# include also .git repo so we archive the whole history
		tar cJf "$BN" "${gitbase}-${tag}"
		# upload if possible to aws
		aws --profile cf s3 cp "$BN" "s3://azusa/src/main/${PKG/.//}/${BN}"
	fi
}

fetchgitbranch() {
	# fetchgit repository tag
	local gitbase
	gitbase="$(basename $1)"
	gitbase="${gitbase/.git}"
	local branch
	branch="$2"

	# we only clone, no checkout, so it's relatively faster than fetching all the dependencies
	echo " *** Grabbing metadata from git: $1"
	git clone --filter=blob:none --depth 1 --no-checkout --single-branch --branch "$branch" "$1" "${gitbase}-${branch}"
	cd "${gitbase}-${branch}"
	GIT_COMMIT="$(git rev-parse "${branch}")"
	GIT_COMMIT_SHORT="${GIT_COMMIT:0:7}"
	GIT_DATEVER="$(TZ=UTC git show -s --format=%cd --date=format-local:%Y%m%d.%H%M%S "${GIT_COMMIT}")"
	local gitdir
	gitdir="${gitbase}-${branch}.${GIT_DATEVER}.${GIT_COMMIT_SHORT}"
	local BN
	BN="${gitdir}.tar.xz"

	# alter PV*
	PV="${PV}.${GIT_DATEVER}"
	PVR="${PV}" # drops R - TODO fixme
	PVRF="${PVR}.${OS}.${ARCH}"

	cd ..

	# try to get from our system
	wget --ca-certificate=/etc/ssl/certs/ca-certificates.crt -O "$BN" "$(echo "https://pkg.azusa.jp/src/main/${CATEGORY}/${PN}/${BN}" | sed -e 's/+/%2B/g')" || true
	if [ -s "$BN" ]; then
		extract "$BN"
		# owner might differ, add directory to safe.directory
		git config --global --add safe.directory "${S}"
		return
	fi

	# ok we don't have it, do the recursive fetch
	mv "${gitbase}-${branch}" "$gitdir"
	cd "$gitdir"

	echo " *** Downloading from git: $1 ($branch → $GIT_COMMIT_SHORT, $GIT_DATEVER)"
	S="${PWD}"
	git checkout --detach "$GIT_COMMIT" # checkout will download the branch, we specify the hash in case there was a new commit
	git submodule update --recursive --init
	cd ..

	if [ -f "$HOME/.aws/credentials" ]; then
		echo "Archiving for upload..."
		# include also .git repo so we archive the whole history
		tar cJf "$BN" "$gitdir"
		# upload if possible to aws
		aws --profile cf s3 cp "$BN" "s3://azusa/src/main/${PKG/.//}/${BN}"
	fi
}
