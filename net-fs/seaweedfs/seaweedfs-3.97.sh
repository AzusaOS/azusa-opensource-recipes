#!/bin/sh
source "../../common/init.sh"

get https://github.com/seaweedfs/seaweedfs/archive/refs/tags/${PV}.tar.gz "${P}.tar.gz"
#acheck
envcheck

cd "${S}/weed"

export PATH="$(realpath /pkg/main/dev-lang.go.dev/bin):$PATH"

echo -n "Using: "
go version

export GOBIN="${D}/pkg/main/${PKG}.core.${PVRF}/bin"
mkdir -pv "$GOBIN"
go install -ldflags="-s -w"

finalize
