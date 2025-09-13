#!/bin/sh
source "../../common/init.sh"

get https://github.com/cacalabs/libcaca/releases/download/v${PV}/${P}.tar.bz2
acheck

cd "${T}"

importpkg X zlib media-libs/libglvnd media-libs/freeglut

doconf --disable-java --disable-csharp --disable-ruby --disable-static --disable-doc

make
make install DESTDIR="${D}"

finalize
