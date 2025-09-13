#!/bin/sh
source "../../common/init.sh"

get https://gstreamer.freedesktop.org/src/gst-plugins-base/${P}.tar.xz
acheck

importpkg media-libs/libsdl zlib media-libs/glu dev-util/valgrind media-libs/libglvnd

cd "${T}"

domeson -Dtools=enabled

finalize
