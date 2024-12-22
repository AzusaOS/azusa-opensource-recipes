#!/bin/sh
source "../../common/init.sh"
envcheck
# do not use acheck so we keep networking

export PATH="/pkg/main/dev-lang.go.dev/bin:$PATH"

echo -n "Using: "
go version

export GOBIN="${D}/pkg/main/${PKG}.core.${PVRF}/bin"
mkdir -pv "$GOBIN"
go install -v github.com/golangci/golangci-lint/cmd/golangci-lint@v${PV}
if [ ! -f "$GOBIN/golangci-lint" ]; then
	echo "Build failed"
	exit
fi

finalize
