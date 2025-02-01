#!/bin/sh
source "../../common/init.sh"

get https://github.com/fmtlib/fmt/archive/${PV}.tar.gz "${P}.tar.gz"
acheck

cd "${T}"

docmake -DBUILD_SHARED_LIBS=YES -DFMT_CMAKE_DIR=/pkg/main/${PKG}.dev.${PVRF}/cmake/fmt -DFMT_LIB_DIR=/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX -DFMT_TEST=NO

finalize
