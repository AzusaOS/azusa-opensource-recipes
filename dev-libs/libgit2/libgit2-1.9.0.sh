#!/bin/sh
source "../../common/init.sh"

get https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz ${P}.tar.gz
acheck

cd "${T}"

importpkg net-libs/libssh2 dev-libs/openssl

docmake -DBUILD_SHARED_LIBS=YES -DUSE_SSH=ON -DTHREADSAFE=ON -DUSE_HTTPS=ON -DBUILD_CLAR=OFF -DUSE_BUNDLED_ZLIB=OFF

finalize
