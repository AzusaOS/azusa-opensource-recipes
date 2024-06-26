#!/bin/sh
source "../../common/init.sh"

get http://ftp.gnu.org/gnu/libtool/${P}.tar.gz
acheck

cd "${S}"

apatch "$FILESDIR/libtool-2.4.7-grep-3.8.patch" "$FILESDIR/libtool-2.4.7-werror-lto.patch"

cd "${T}"

# configure & build
doconf

make
make install DESTDIR="${D}"

finalize
