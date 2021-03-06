#!/bin/sh
source "../../common/init.sh"

get http://archive.xfce.org/src/xfce/${PN}/${PV%.*}/${P}.tar.bz2
acheck

importpkg x11-libs/libX11 x11-base/xorg-proto zlib sys-power/upower x11-libs/libXext

cd "${T}"

doconf

make
make install DESTDIR="${D}"

finalize
