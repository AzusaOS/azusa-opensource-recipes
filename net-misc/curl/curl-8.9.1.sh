#!/bin/sh
source "../../common/init.sh"

get https://curl.haxx.se/download/${P}.tar.xz
acheck

cd "${T}"

importpkg libbrotlidec app-arch/zstd net-libs/libssh2 dev-libs/nettle net-libs/gnutls net-libs/ngtcp2

doconf --with-gnutls --with-ngtcp2 --with-libssh2 --enable-websockets

make
make install DESTDIR="${D}"

finalize
