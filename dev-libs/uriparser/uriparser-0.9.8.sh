#!/bin/sh
source "../../common/init.sh"

get https://github.com/uriparser/uriparser/releases/download/${P}/${P}.tar.bz2
acheck

cd "${T}"

docmake -DBUILD_SHARED_LIBS=YES -DURIPARSER_BUILD_TESTS=OFF

finalize
