#!/bin/sh
source "../../common/init.sh"

get https://github.com/libsdl-org/sdl12-compat/archive/refs/tags/release-${PV}.tar.gz ${P}.tar.gz
acheck

cd "${T}"

importpkg X media-libs/libsdl2

docmake -DBUILD_SHARED_LIBS=ON

finalize
