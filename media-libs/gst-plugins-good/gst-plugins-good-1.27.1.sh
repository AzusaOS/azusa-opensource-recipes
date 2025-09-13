#!/bin/sh
source "../../common/init.sh"

get https://gstreamer.freedesktop.org/src/${PN}/${P}.tar.xz
acheck

importpkg zlib app-arch/bzip2 dev-util/valgrind media-libs/libcaca

cd "${T}"

domeson

finalize
