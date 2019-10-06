#!/bin/sh
source "../../common/init.sh"

get http://ftp.gnome.org/pub/gnome/sources/librsvg/2.46/${P}.tar.xz
acheck

cd "${T}"

importpkg uuid libbsd app-arch/bzip2
doconf --enable-vala --disable-static

make
make install DESTDIR="${D}"

finalize
