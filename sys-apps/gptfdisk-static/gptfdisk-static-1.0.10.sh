#!/bin/sh
source "../../common/init.sh"

PN=gptfdisk get https://downloads.sourceforge.net/${PN}/${PN}/${PV}/gptfdisk-${PV}.tar.gz
acheck

cd "${S}"

apatch "$FILESDIR/gptfdisk-1.0.10_utf16-to-utf8-conversion.patch"

importpkg sys-apps/util-linux sys-libs/ncurses dev-libs/popt

export LDFLAGS="$LDFLAGS -static"

make gdisk sgdisk fixparts

dosbin gdisk sgdisk fixparts
doman *.8
dodoc NEWS README

finalize
