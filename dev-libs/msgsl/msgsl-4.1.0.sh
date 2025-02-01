#!/bin/sh
source "../../common/init.sh"

get https://github.com/microsoft/GSL/archive/refs/tags/v$PV.tar.gz $P.tar.gz
acheck

cd "${T}"

importpkg dev-cpp/gtest

docmake -DBUILD_SHARED_LIBS=YES -DGSL_TEST=OFF

finalize
