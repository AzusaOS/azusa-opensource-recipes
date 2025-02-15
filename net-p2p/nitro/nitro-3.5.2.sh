#!/bin/sh
source "../../common/init.sh"

fetchgit https://github.com/OffchainLabs/nitro.git "v${PV}"
envcheck
# do not use acheck so we keep networking

export PATH="/pkg/main/dev-lang.go.dev.1.22/bin:$PATH"

echo -n "Using: "
go version

CARGO_VERSION="1.80.1"
export PATH="/pkg/main/dev-lang.rust.core.$CARGO_VERSION/bin:$PATH"

cd "${S}"

# first, build brotli wasm (makefile will attempt to use docker for this, we don't want docker)
PATH="/pkg/main/dev-util.emscripten.core/bin:$PATH" ./scripts/build-brotli.sh -w

# error hardhat@2.12.4: The engine "node" is incompatible with this module. Expected version "^14.0.0 || ^16.0.0 || ^18.0.0". Got "22.9.0"
# give it node18 so it's happy
export PATH="/pkg/main/net-libs.nodejs.core.18/bin:$PATH"

export WASI_SYSROOT=/pkg/main/sys-devel.wasi-sdk.data/share/wasi-sysroot

# make all would call make lint which fails
make build
mkdir -p "${D}/pkg/main"
# binaries do not seem to depend on the shipped libs, check & patchelf as needed
#patchelf --add-rpath "/pkg/main/${PKG}.mod.${PVRF}/lib" target/bin/*
mv target "${D}/pkg/main/${PKG}.mod.${PVRF}"

finalize
