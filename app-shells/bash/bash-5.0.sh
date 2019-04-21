#!/bin/sh
source "../../common/init.sh"

get http://ftp.gnu.org/gnu/bash/${P}.tar.gz

echo "Compiling ${P} ..."
cd "${T}"

# configure & build
${CHPATH}/${P}/configure >configure.log 2>&1 --prefix=/pkg/main/${PKG}.core.${PVR} --sysconfdir=/etc \
--includedir=/pkg/main/${PKG}.dev.${PVR}/include --libdir=/pkg/main/${PKG}.libs.${PVR}/lib --datarootdir=/pkg/main/${PKG}.core.${PVR} \
--mandir=/pkg/main/${PKG}.doc.${PVR}/man --docdir=/pkg/main/${PKG}.doc.${PVR}/doc \
--without-bash-malloc --with-installed-readline

make >make.log 2>&1
make >make_install.log 2>&1 install DESTDIR="${D}"

finalize
cleanup