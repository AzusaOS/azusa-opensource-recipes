#!/bin/sh
source "../../common/init.sh"

get http://ftp.gnu.org/gnu/${PN}/${P}.tar.gz

cd "${P}"

patch -p1 <"$FILESDIR/make-4.2.1.patch"

cd "${T}"

doconf --without-guile

make
make install DESTDIR="${D}"

finalize
