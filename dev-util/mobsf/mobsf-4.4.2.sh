#!/bin/sh
source "../../common/init.sh"

get https://github.com/MobSF/Mobile-Security-Framework-MobSF/archive/refs/tags/v$PV.tar.gz "${P}.tar.gz"
acheck

cd "${T}"

importpkg zlib

doconf

make
make install DESTDIR="${D}"

finalize
