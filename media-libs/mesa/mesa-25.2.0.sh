#!/bin/sh
source "../../common/init.sh"

get https://mesa.freedesktop.org/archive/${P}.tar.xz
acheck

GALLIUM_DRV="all"
#GALLIUM_DRV="i915,nouveau,r600,radeonsi,svga,swrast,virgl"

cd "${T}"

importpkg zlib X x11-libs/libxshmfence x11-libs/libXext x11-libs/libX11 x11-libs/libXxf86vm x11-libs/libXfixes x11-libs/libXdamage sys-libs/libunwind sys-apps/lm-sensors dev-util/directx-headers

domeson -Dshared-glapi=enabled -Degl=enabled -Dexpat=enabled -Dgbm=enabled -Dglvnd=enabled -Dvideo-codecs="h264dec,h264enc,h265dec,h265enc,vc1dec" -Dgallium-drivers=$GALLIUM_DRV -Dglx=dri -Dvalgrind=disabled

finalize
