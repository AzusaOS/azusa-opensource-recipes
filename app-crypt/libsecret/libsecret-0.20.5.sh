#!/bin/sh
source "../../common/init.sh"

get http://ftp.gnome.org/pub/gnome/sources/${PN}/${PV%.*}/${P}.tar.xz
acheck

cd "${S}"

sed '/valgrind/d' -i egg/egg-testing.c

cd "${T}"

importpkg dev-libs/libgcrypt

# TODO fix man
domeson

finalize
