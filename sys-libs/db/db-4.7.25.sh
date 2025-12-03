#!/bin/sh
source "../../common/init.sh"

get http://download.oracle.com/berkeley-db/${P}.tar.gz
acheck

cd "${T}"

CONFPATH="${CHPATH}/${P}/dist/configure" doconf --enable-compat185 --enable-dbm --disable-static --enable-cxx

make || /bin/bash -i
make install DESTDIR="${D}"

finalize
