#!/bin/sh
source "../../common/init.sh"

get https://miniupnp.tuxfamily.org/files/${P}.tar.gz
acheck

cd "${S}"

apatch "$FILESDIR/libnatpmp-20150609-gentoo.patch"

make
# Override HEADERS for missing declspec.h wrt #506832
make HEADERS="natpmp.h natpmp_declspec.h" PREFIX="${D}/pkg/main/${PKG}.core.${PVRF}" INSTALLPREFIX="${D}/pkg/main/${PKG}.core.${PVRF}" GENTOO_LIBDIR="lib$LIB_SUFFIX" install

dodoc Changelog.txt README
doman natpmpc.1

finalize
