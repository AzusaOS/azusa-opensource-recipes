#!/bin/sh
source "../../common/init.sh"

get https://github.com/projectatomic/${PN}/releases/download/v${PV}/${P}.tar.xz
acheck

cd "${T}"

importpkg sys-libs/libcap

domeson -Dman=disabled

finalize
