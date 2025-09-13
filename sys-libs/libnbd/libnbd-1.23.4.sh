#!/bin/sh
source "../../common/init.sh"

MY_PV=${PV%.*}
[[ $(( ${MY_PV#*.} % 2 )) -eq 0 ]] && SD="stable" || SD="development"
get https://download.libguestfs.org/libnbd/${MY_PV}-${SD}/${P}.tar.gz
acheck

cd "${S}"

doconf --disable-golang --disable-rust

make
make install DESTDIR="${D}"

finalize
