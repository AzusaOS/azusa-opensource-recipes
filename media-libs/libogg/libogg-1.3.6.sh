#!/bin/sh
source "../../common/init.sh"

get https://downloads.xiph.org/releases/ogg/${P}.tar.gz
acheck

cd "${T}"

doconf

make
make install DESTDIR="${D}"

finalize
