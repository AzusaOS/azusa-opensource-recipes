#!/bin/sh
source "../../common/init.sh"

get https://github.com/capstone-engine/capstone/archive/${PV}.tar.gz ${P}.tar.gz
acheck

cd "${T}"

docmake -DBUILD_SHARED_LIBS=ON

finalize
