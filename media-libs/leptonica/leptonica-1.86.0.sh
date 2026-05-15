#!/bin/sh
source "../../common/init.sh"

get https://github.com/DanBloomberg/${PN}/releases/download/${PV}/${P}.tar.gz
acheck

cd "${T}"

importpkg zlib media-libs/giflib

doconf --enable-shared --with-giflib --with-jpeg --with-libpng --with-libtiff --with-libwebp --with-libwebpmux --with-zlib --enable-programs

make
make install DESTDIR="${D}"

finalize
