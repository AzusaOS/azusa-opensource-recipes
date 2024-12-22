#!/bin/sh
source "../../common/init.sh"

get https://github.com/foundry-rs/foundry/archive/refs/tags/v${PV}.tar.gz ${P}.tar.gz
envcheck # for cargo

cd "${S}"

cargo build --release --features cast/aws-kms,forge/aws-kms

mkdir -p "${D}/pkg/main/${PKG}.core.${PVRF}/bin"

for foo in forge cast anvil chisel; do
	strip target/release/$foo
	mv target/release/$foo "${D}/pkg/main/${PKG}.core.${PVRF}/bin/$foo"
done

finalize
