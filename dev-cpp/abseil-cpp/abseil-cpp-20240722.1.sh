#!/bin/sh
source "../../common/init.sh"

get https://github.com/abseil/abseil-cpp/archive/${PV}.tar.gz ${P}.tar.gz
acheck

cd "${T}"

docmake -DBUILD_SHARED_LIBS=ON -DABSL_ENABLE_INSTALL=TRUE -DCMAKE_CXX_STANDARD=17 -DABSL_PROPAGATE_CXX_STD=TRUE -DABSL_USE_EXTERNAL_GOOGLETEST=ON -DABSL_BUILD_TEST_HELPERS=ON

finalize
