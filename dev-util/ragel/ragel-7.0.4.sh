#!/bin/sh
source "../../common/init.sh"

get https://www.colm.net/files/ragel/${P}.tar.gz
acheck

cd "${T}"

doconf

make
make install DESTDIR="${D}"

finalize
