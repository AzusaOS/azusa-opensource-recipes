#!/bin/sh
source "../../common/init.sh"

get https://gstreamer.freedesktop.org/src/gst-plugins-bad/${P}.tar.xz
acheck

cd "${T}"

importpkg app-arch/bzip2 dev-util/valgrind media-libs/openh264 media-libs/openal media-libs/libaom zlib

domeson -Dshm=enabled -Dipcpipeline=enabled -Dhls=disabled -Dbz2=enabled -Dva=enabled -Dudev=enabled -Dlibrfb=enabled -Dx11=enabled -Dwayland=disabled -Drtmp=disabled -Dwebrtc=disabled -Daom=disabled -Dgpl=enabled

finalize
