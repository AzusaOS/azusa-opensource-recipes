#!/bin/sh
source "../../common/init.sh"

get https://github.com/Yubico/${PN}/archive/${PV}.tar.gz "${P}.tar.gz"
acheck

cd "${T}"

importpkg dev-libs/libcbor

docmake -DBUILD_SHARED_LIBS=YES -DUSE_NFC=YES

finalize
