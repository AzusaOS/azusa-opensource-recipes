#!/bin/sh
source "../../common/init.sh"

get https://releases.pagure.org/${PN}/${P}.tar.gz
acheck

cd "${P}"

make prefix="/pkg/main/${PKG}.core.${PVRF}"
make install DESTDIR="${D}" prefix="/pkg/main/${PKG}.core.${PVRF}"

finalize
