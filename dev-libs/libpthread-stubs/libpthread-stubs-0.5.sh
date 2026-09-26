#!/bin/sh
source "../../common/init.sh"

get https://xcb.freedesktop.org/dist/${P}.tar.gz

cd "${T}"

doconf

make install DESTDIR="${D}"

finalize
