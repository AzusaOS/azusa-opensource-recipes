#!/bin/sh
source "../../common/init.sh"

get https://github.com/strukturag/libde265/releases/download/v${PV}/${P}.tar.gz
acheck

cd "${T}"

doconf --enable-log-error --enable-enc265 --enable-dec265

make
make install DESTDIR="${D}"

finalize
