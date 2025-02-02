#!/bin/sh
source "../../common/init.sh"

get https://mirrors.edge.kernel.org/pub/linux/utils/net/iproute2/${P}.tar.xz
acheck

cd "${P}"

importpkg sys-libs/libcap

doconf

make
make install DESTDIR="${D}"

cd "${D}"

mkdir -p "pkg/main/${PKG}.core.${PVRF}" "pkg/main/${PKG}.doc.${PVRF}" "pkg/main/${PKG}.dev.${PVRF}"

mv sbin "pkg/main/${PKG}.core.${PVRF}"
mv usr/share "pkg/main/${PKG}.core.${PVRF}"
mv usr/include "pkg/main/${PKG}.dev.${PVRF}"
rm -fr usr

finalize
