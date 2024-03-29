#!/bin/sh
source "../../common/init.sh"

get https://download.sourceforge.net/${PN}/${P}.tar.gz
acheck

cd "${S}"

sed -i -e '/CFLAGS/s:-O3::' configure
# remove -Werror, gentoo bug 493940
sed -i -e '/WARNING_CFLAGS/s:-Werror::' configure

cd "${T}"

doconf

make
make install DESTDIR="${D}"

finalize
