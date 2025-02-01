#!/bin/sh
source "../../common/init.sh"

get https://github.com/rrthomas/enchant/releases/download/v${PV}/${P}.tar.gz
acheck

cd "${T}"

importpkg app-text/hunspell

doconf --disable-static

make
make install DESTDIR="${D}"

ln -snfv enchant-2 "${D}/pkg/main/${PKG}.dev.${PVRF}/include/enchant"
ln -snfv libenchant-2.so "${D}/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX/libenchant.so"
ln -snfv enchant-2.pc "${D}/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX/pkgconfig/enchant.pc"
ln -snfv enchant-2 "${D}/pkg/main/${PKG}.core.${PVRF}/bin/enchant"

finalize
