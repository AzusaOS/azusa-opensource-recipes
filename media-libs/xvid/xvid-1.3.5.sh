#!/bin/sh
source "../../common/init.sh"

get http://downloads.xvid.org/downloads/xvidcore-${PV}.tar.bz2

acheck

cd xvidcore/build/generic

doconf

make
make install DESTDIR="${D}"

# remove static lib
rm "${D}/pkg/main/${PKG}.libs.${PVR}/lib64/libxvidcore.a"

finalize
