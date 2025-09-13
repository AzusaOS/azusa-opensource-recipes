#!/bin/sh
source "../../common/init.sh"

#get http://rpm5.org/files/popt/${P}.tar.gz
#get http://ftp.rpm.org/${PN}/releases/${PN}-1.x/${P}.tar.gz
get ftp://anduin.linuxfromscratch.org/BLFS/popt/${P}.tar.gz
acheck

cd "${T}"

doconf

make
make install DESTDIR="${D}"

finalize
