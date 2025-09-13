#!/bin/sh
source "../../common/init.sh"

get https://downloads.sourceforge.net/${PN}/${PN}/${PV}/${P}.tar.gz
acheck

cd "${S}"

apatch "$FILESDIR/gptfdisk-1.0.10_utf16-to-utf8-conversion.patch"

importpkg sys-apps/util-linux sys-libs/ncurses dev-libs/popt

sed -i -e 's/CGDISK_LDLIBS=-lncursesw/CGDISK_LDLIBS=-lncursesw -ltinfow/' Makefile

make

dosbin gdisk sgdisk cgdisk fixparts
doman *.8
dodoc NEWS README

finalize
