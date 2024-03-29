#!/bin/sh
source "../../common/init.sh"

get https://c-ares.haxx.se/download/${P}.tar.gz
acheck

cd "${T}"

# configure & build
doconf

make
make install DESTDIR="${D}"

finalize
