#!/bin/sh
source "../../common/init.sh"

get https://github.com/p11-glue/${PN}/releases/download/${PV}/${P}.tar.xz
acheck

cd "${T}"

doconf --without-systemd

make
make install DESTDIR="${D}"

finalize
