#!/bin/sh
source "../../common/init.sh"

get https://www.x.org/pub/individual/lib/${P}.tar.xz
acheck

cd "${T}"

importpkg sys-apps/util-linux

doconf --localstatedir=/var

make
make install DESTDIR="${D}"

finalize
