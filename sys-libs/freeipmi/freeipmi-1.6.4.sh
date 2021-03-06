#!/bin/sh
source "../../common/init.sh"

get https://ftp.gnu.org/gnu/${PN}/${P}.tar.gz
acheck

importpkg libgcrypt

cd "${T}"

doconf

make
make install DESTDIR="${D}"

finalize
