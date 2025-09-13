#!/bin/sh
source "../../common/init.sh"

get https://github.com/sahlberg/libiscsi/archive/refs/tags/${PV}.tar.gz "${P}.tar.gz"
acheck

cd "${S}"

aautoreconf

#cd "${T}"
importpkg dev-util/cunit

doconf

make
make install DESTDIR="${D}"

finalize
