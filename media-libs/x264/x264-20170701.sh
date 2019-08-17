#!/bin/sh
source "../../common/init.sh"

P=x264-snapshot-${PV}-2245

get https://download.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-${PV}-2245.tar.bz2

cd "${T}"

doconf

make
make install DESTDIR="${D}"

finalize
