#!/bin/sh
source "../../common/init.sh"

get http://archive.xfce.org/src/xfce/${PN}/${PV%.*}/${P}.tar.bz2
acheck

importpkg zlib

cd "${T}"

doconf

make
make install DESTDIR="${D}"

finalize
