#!/bin/sh
source "../../common/init.sh"

get https://archive.hadrons.org/software/libmd/${P}.tar.xz
acheck

cd "${T}"

doconf

make
make install DESTDIR="${D}"

finalize
