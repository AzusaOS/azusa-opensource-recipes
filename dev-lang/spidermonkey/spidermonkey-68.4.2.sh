#!/bin/sh
source "../../common/init.sh"

get http://ftp.gnome.org/pub/gnome/teams/releng/tarballs-needing-help/mozjs/mozjs-${PV}.tar.bz2

cd "${T}"

"${S}/js/src/configure" --prefix=/pkg/main/${PKG}.core.${PVRF} \
	--includedir=/pkg/main/${PKG}.dev.${PVRF}/include --libdir=/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX \
	--with-intl-api --with-system-zlib --with-system-icu --disable-jemalloc --enable-readline

make
make install DESTDIR="${D}"

finalize
