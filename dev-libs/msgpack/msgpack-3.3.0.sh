#!/bin/sh
source "../../common/init.sh"

get https://github.com/${PN}/${PN}-c/releases/download/cpp-${PV}/${P}.tar.gz
acheck

cd "${T}"

docmake -DBUILD_SHARED_LIBS=YES -DMSGPACK_BUILD_EXAMPLES=OFF -DMSGPACK_BUILD_TESTS=OFF

finalize
