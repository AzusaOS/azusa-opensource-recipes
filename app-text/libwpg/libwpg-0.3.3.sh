#!/bin/sh
source "../../common/init.sh"

get https://download.sourceforge.net/${PN}/${P}.tar.xz
acheck

cd "${T}"

doconf

make
make install DESTDIR="${D}"

finalize
