#!/bin/sh
source "../../common/init.sh"

fetchgit https://github.com/coral-xyz/anchor.git v"${PV}"
envcheck

# we keep networking alive for cargo
cd "${S}"
cargo update time
cargo build --release --workspace --package anchor-cli

mkdir -p "${D}/pkg/main/${PKG}.core.${PVRF}/bin"
mv target/release/anchor "${D}/pkg/main/${PKG}.core.${PVRF}/bin"

finalize
