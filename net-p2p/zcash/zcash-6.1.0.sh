#!/bin/sh
source "../../common/init.sh"

get https://github.com/zcash/zcash/archive/refs/tags/v${PV}.tar.gz ${P}.tar.gz
acheck

cd "${S}"

aautoreconf

cd "${T}"

importpkg dev-libs/boost dev-libs/libevent sys-libs/db:5.3 net-libs/miniupnpc net-libs/zeromq

doconf --with-boost --with-boost-libdir="/pkg/main/dev-libs.boost.libs/lib$LIB_SUFFIX" --enable-asm --enable-wallet --with-daemon --disable-bench --without-libs --without-gui --disable-ccache --disable-static

make -j"$NPROC"
make install DESTDIR="${D}"

finalize
