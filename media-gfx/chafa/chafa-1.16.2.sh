#!/bin/sh
source "../../common/init.sh"

get https://hpjansson.org/chafa/releases/${P}.tar.xz
acheck

cd "${T}"

doconf --disable-man --with-tools --with-webp

make
make install DESTDIR="${D}"

finalize
