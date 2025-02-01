#!/bin/sh
source "../../common/init.sh"

get https://github.com/microsoft/mimalloc/archive/refs/tags/v${PV}.tar.gz "${P}.tar.gz"
acheck

cd "${T}"

docmake -DMI_SECURE=ON -DBUILD_SHARED_LIBS=YES -DMI_INSTALL_TOPLEVEL=ON -DMI_BUILD_OBJECT=OFF -DMI_BUILD_STATIC=OFF

finalize
