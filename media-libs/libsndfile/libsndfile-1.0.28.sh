#!/bin/sh
source "../../common/init.sh"

get http://www.mega-nerd.com/libsndfile/files/${P}.tar.gz
acheck

cd "${T}"

importpkg media-libs/alsa-lib

doconf --disable-static

make
make install DESTDIR="${D}"

finalize
