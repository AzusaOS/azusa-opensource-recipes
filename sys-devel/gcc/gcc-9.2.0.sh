#!/bin/sh
source "../../common/init.sh"

get http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/${P}/${P}.tar.xz

cd "${T}"

export SED=sed

# Fix C++ building for gcc
GCC_VERSION=`gcc -dumpversion`
GCC_MACHINE=`gcc -dumpmachine`
export CXXFLAGS="-I/pkg/main/sys-devel.gcc.core.$GCC_VERSION/include/c++/$GCC_VERSION -I/pkg/main/sys-devel.gcc.core.$GCC_VERSION/include/c++/$GCC_VERSION/$GCC_MACHINE"

# make sure gcc can find stuff like -lz
export LDFLAGS="-L/pkg/main/core.symlinks/full/lib$LIB_SUFFIX"

export LD_LIBRARY_PATH=/pkg/main/dev-libs.isl.libs/lib$LIB_SUFFIX:/pkg/main/dev-libs.mpfr.libs/lib$LIB_SUFFIX:/pkg/main/dev-libs.mpc.libs/lib$LIB_SUFFIX:/pkg/main/dev-libs.gmp.libs/lib$LIB_SUFFIX

# configure & build
callconf --prefix=/pkg/main/${PKG}.core.${PVR} --infodir=/pkg/main/${PKG}.doc.${PVR}/info --mandir=/pkg/main/${PKG}.doc.${PVR}/man --docdir=/pkg/main/${PKG}.doc.${PVR}/gcc \
--with-gcc-major-version-only \
--enable-languages=c,c++ --disable-multilib --disable-bootstrap --disable-libmpx --with-system-zlib \
--with-mpfr-include=`realpath /pkg/main/dev-libs.mpfr.dev/include` --with-mpfr-lib=`realpath /pkg/main/dev-libs.mpfr.libs/lib$LIB_SUFFIX` \
--with-mpc-include=`realpath /pkg/main/dev-libs.mpc.dev/include` --with-mpc-lib=`realpath /pkg/main/dev-libs.mpc.libs/lib$LIB_SUFFIX` \
--with-gmp-include=`realpath /pkg/main/dev-libs.gmp.dev/include` --with-gmp-lib=`realpath /pkg/main/dev-libs.gmp.libs/lib$LIB_SUFFIX` \
--with-isl-include=`realpath /pkg/main/dev-libs.isl.dev/include` --with-isl-lib=`realpath /pkg/main/dev-libs.isl.libs/lib$LIB_SUFFIX`


# prepare things a bit
if [ "$MULTILIB" = yes ]; then
	mkdir -p pkg/main/${PKG}.libs.${PVR}/lib$LIB_SUFFIX
	ln -s lib$LIB_SUFFIX pkg/main/${PKG}.libs.${PVR}/lib
fi

make -j8
make install DESTDIR="${D}"

ln -sv gcc "${D}/pkg/main/${PKG}.core.${PVR}/bin/cc"

cd "${D}"

# do not use finalize because we depend on location of some files
archive
