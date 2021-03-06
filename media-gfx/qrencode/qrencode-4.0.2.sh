#!/bin/sh
source "../../common/init.sh"

get https://fukuchi.org/works/${PN}/${P}.tar.bz2
acheck

cd "${T}"

doconf --disable-static

make
make install DESTDIR="${D}"

finalize
