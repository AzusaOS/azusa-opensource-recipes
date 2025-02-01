#!/bin/sh
source "../../common/init.sh"

get https://github.com/google/leveldb/archive/${PV}.tar.gz
acheck

cd "${T}"

docmake -DBUILD_SHARED_LIBS=YES -DLEVELDB_BUILD_TESTS=NO

finalize
