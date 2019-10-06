#!/bin/sh
source "../../common/init.sh"

get https://www.gnupg.org/ftp/gcrypt/${PN}/${P}.tar.bz2
acheck

cd "${T}"

importpkg dev-libs/libassuan

doconf

make
make install DESTDIR="${D}"

finalize
