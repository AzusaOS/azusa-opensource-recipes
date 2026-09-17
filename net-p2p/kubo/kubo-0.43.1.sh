#!/bin/sh
source "../../common/init.sh"

fetchgit https://github.com/ipfs/kubo.git v${PV}

envcheck
# do not use acheck so we keep networking (go mod download)

export PATH="/pkg/main/dev-lang.go.dev/bin:$PATH"

cd "${S}"

echo -n "Using: "
go version

# builds cmd/ipfs/ipfs with -trimpath and the version/commit ldflags from
# mk/git.mk (git-tag is picked up from the checked-out release tag)
make build

install -v -D -t "${D}/pkg/main/${PKG}.core.${PVRF}/bin" cmd/ipfs/ipfs

finalize
