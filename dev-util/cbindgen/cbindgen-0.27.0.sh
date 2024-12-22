#!/bin/sh
source "../../common/init.sh"

get https://github.com/mozilla/cbindgen/archive/refs/tags/v${PV}.tar.gz ${P}.tar.gz
envcheck # for cargo

cd "${S}"

cargo install --path "${S}" --root "${D}/pkg/main/${PKG}.core.${PVRF}"

#cargo build --release
#mkdir -p "${D}/pkg/main/${PKG}.core.${PVRF}/bin"
#/bin/bash -i

finalize
