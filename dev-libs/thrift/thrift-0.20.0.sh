#!/bin/sh
source "../../common/init.sh"

get https://archive.apache.org/dist/${PN}/${PV}/${P}.tar.gz
acheck

cd "${T}"

importpkg zlib dev-libs/boost dev-libs/libevent

docmake -DBUILD_SHARED_LIBS=YES -DBUILD_CPP=ON -DBUILD_C_GLIB=OFF -DBUILD_JAVA=OFF -DBUILD_JAVASCRIPT=OFF -DBUILD_NODEJS=OFF -DBUILD_PYTHON=OFF -DBUILD_TESTING=OFF -DWITH_LIBEVENT=ON -DWITH_OPENSSL=ON -DWITH_ZLIB=ON -Wno-dev

finalize
