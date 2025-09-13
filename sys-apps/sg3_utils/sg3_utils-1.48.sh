#!/bin/sh
source "../../common/init.sh"

get https://sg.danny.cz/sg/p/${P}.tar.xz
acheck

cd "${T}"

importpkg zlib

doconf

make
make install DESTDIR="${D}"

finalize
