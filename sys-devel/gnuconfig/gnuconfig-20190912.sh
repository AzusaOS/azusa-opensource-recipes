#!/bin/sh
source "../../common/init.sh"

get https://dev.gentoo.org/~whissi/dist/${PN}/${P}.tar.bz2
acheck

apatch *.patch

mkdir -p "${D}/pkg/main/${PKG}.core.${PVRF}/share/${PN}"

cp config.{sub,guess} "${D}/pkg/main/${PKG}.core.${PVRF}/share/${PN}"
chmod +x "${D}/pkg/main/${PKG}.core.${PVRF}/share/${PN}"/config.{sub,guess}

finalize
