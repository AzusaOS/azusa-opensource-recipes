#!/bin/sh
source "../../common/init.sh"

get https://dl.google.com/${PN}/go${PV}.src.tar.gz

cd "go/src"

export GOOS="${OS}"
export GOARCH="${ARCH}"
export GOROOT_FINAL="/pkg/main/${PKG}.dev.${PVRF}"
export GOROOT="${D}/pkg/main/${PKG}.dev.${PVRF}"
export PATH="/pkg/main/dev-lang.go.dev.${OS}.${ARCH}/bin/:$PATH"
if [ x"$ARCH" = x"386" ]; then
	export CGO_CFLAGS=-fno-stack-protector # https://github.com/golang/go/issues/54313
fi

echo "Using: GOOS=$GOOS GOARCH=$GOARCH GOROOT_FINAL=$GOROOT_FINAL"

./all.bash

# install
cd ../..
mkdir -p "${D}/pkg/main/"
mv go "${D}/pkg/main/${PKG}.dev.${PVRF}"

finalize
