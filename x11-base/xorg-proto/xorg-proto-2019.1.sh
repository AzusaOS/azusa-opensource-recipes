#!/bin/sh
source "../../common/init.sh"

get https://xorg.freedesktop.org/archive/individual/proto/xorgproto-${PV}.tar.bz2

cd "${T}"

doconf

make
make install DESTDIR="${D}"

finalize
