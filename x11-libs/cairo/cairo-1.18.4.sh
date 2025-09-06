#!/bin/sh
source "../../common/init.sh"

get https://gitlab.freedesktop.org/cairo/cairo/-/archive/${PV}/cairo-${PV}.tar.bz2
acheck

cd "${T}"

importpkg zlib dev-libs/lzo

domeson

finalize
