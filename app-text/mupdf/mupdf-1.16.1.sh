#!/bin/sh
source "../../common/init.sh"

get https://mupdf.com/downloads/archive/${P}-source.tar.xz
acheck

cd "${S}"

importpkg media-libs/freeglut

apatch $FILESDIR/${P}-*.patch

USE_SYSTEM_LIBS=yes make

make DESTDIR="${D}" prefix="/pkg/main/${PKG}.core.${PVRF}" build=release docdir="/pkg/main/${PKG}.doc.${PVRF}" install
ln -sfv mupdf-x11 "${D}/pkg/main/${PKG}.core.${PVRF}/bin"

finalize
