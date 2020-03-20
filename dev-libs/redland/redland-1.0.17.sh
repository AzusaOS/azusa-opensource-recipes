#!/bin/sh
source "../../common/init.sh"

get http://download.librdf.org/source/${P}.tar.gz
acheck

cd "${T}"

importpkg mariadb

doconf --with-virtuoso --with-unixodbc --without-iodbc --disable-static --with-bdb --with-mysql --with-sqlite --with-postgresql --without-threads --with-html-dir="/pkg/main/${PKG}.doc.${PVR}/html"

make
make install DESTDIR="${D}"

finalize