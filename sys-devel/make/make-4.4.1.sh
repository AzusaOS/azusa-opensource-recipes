#!/bin/sh
source "../../common/init.sh"

get http://ftp.gnu.org/gnu/${PN}/${P}.tar.gz
acheck

cd "${T}"

doconf --without-guile

make
make install DESTDIR="${D}"

finalize
