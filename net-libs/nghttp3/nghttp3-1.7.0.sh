#!/bin/sh
source "../../common/init.sh"

get https://github.com/ngtcp2/${PN}/releases/download/v${PV}/${P}.tar.bz2
acheck

cd "${T}"

doconf

make
make install DESTDIR="${D}"

finalize
