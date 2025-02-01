#!/bin/sh
source "../../common/init.sh"

get https://salsa.debian.org/${PN}-team/${PN}/-/archive/v${PV}/${PN}-v${PV}.tar.gz
acheck

cd "${T}"

doconf

make
make install DESTDIR="${D}"

finalize
