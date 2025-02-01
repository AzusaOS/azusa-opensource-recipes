#!/bin/sh
source "../../common/init.sh"

get https://github.com/lloyd/yajl/tarball/${PV} ${P}.tar.gz
acheck

cd "${T}"

docmake -DBUILD_SHARED_LIBS=YES

finalize
