#!/bin/sh
source "../../common/init.sh"

get https://github.com/facebook/rocksdb/archive/refs/tags/v${PV}.tar.gz ${P}.tar.gz
acheck

importpkg dev-libs/jemalloc

cd "${S}"

apatch "$FILESDIR/rocksdb-10.1-fixincludes.patch"

docmake -DBUILD_SHARED_LIBS=YES -DFAIL_ON_WARNINGS=OFF -DPORTABLE=ON -DWITH_JEMALLOC=ON -DWITH_TESTS=OFF

finalize
