#!/bin/sh
source "../../common/init.sh"

get https://github.com/${PN}/${PN}/releases/download/${P}/${P}.tar.gz
acheck

cd "${T}"

doconf --disable-java --with-afflib --with-zlib

make
make install DESTDIR="${D}"

finalize
