#!/bin/sh
source "../../common/init.sh"

case $ARCH in
	amd64)
		RUST_ARCH=x86_64
		;;
	*)
		echo "unsupported arch, please add mapping for $ARCH"
		exit 1
esac

get https://static.rust-lang.org/dist/rust-${PV}-${RUST_ARCH}-unknown-linux-gnu.tar.xz
acheck

cd "${S}"
./install.sh --destdir="${D}" --disable-ldconfig --prefix="/pkg/main/${PKG}.core.${PVRF}" --libdir="${D}/pkg/main/${PKG}.libs.${PVRF}/lib${LIB_SUFFIX}"
finalize
