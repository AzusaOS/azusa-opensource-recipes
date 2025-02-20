#!/bin/sh
source "../../common/init.sh"

get https://github.com/dashpay/dash/releases/download/v${PV}/dashcore-${PV}.tar.gz
acheck

importpkg dev-libs/boost dev-libs/libevent sys-libs/db:4.8 dev-libs/gmp sys-libs/libbacktrace

cd "${S}"

aautoreconf

doconf --with-boost-libdir="/pkg/main/dev-libs.boost.libs/lib$LIB_SUFFIX" --enable-asm --without-qtdbus --without-qrencode --enable-wallet --with-daemon --disable-bench --without-libs --without-gui --without-rapidcheck --disable-fuzz --disable-ccache --disable-static --with-system-libsecp256k1 --with-system-univalue
#--with-miniupnpc --enable-upnp-default --enable-zmq --disable-util-cli --disable-util-tx --disable-util-wallet

make -j"$NPROC"
make install DESTDIR="${D}"

finalize
