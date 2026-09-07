#!/bin/sh
source "../../common/init.sh"

get https://github.com/ElementsProject/elements/archive/refs/tags/elements-${PV}.tar.gz "${P}.tar.gz"
acheck

cd "${S}"

aautoreconf

cd "${T}"

# sqlite for descriptor wallets, bdb 4.8 for legacy wallets
importpkg dev-libs/boost dev-libs/libevent sys-libs/db:4.8 sqlite3

doconf --with-boost-libdir="/pkg/main/dev-libs.boost.libs/lib$LIB_SUFFIX" --enable-asm --without-qtdbus --without-qrencode --enable-wallet --with-sqlite=yes --with-bdb --with-daemon --disable-bench --without-libs --without-gui --disable-fuzz --disable-fuzz-binary --disable-ccache --disable-static --disable-tests --disable-gui-tests --without-miniupnpc --without-natpmp

make -j"$NPROC"
make install DESTDIR="${D}"

finalize
