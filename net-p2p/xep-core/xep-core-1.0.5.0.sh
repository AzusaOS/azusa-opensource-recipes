#!/bin/sh
source "../../common/init.sh"

fetchgit https://github.com/ElectraProtocol/XEP-Core.git "v${PV}"
acheck

cd "${S}"

aautoreconf

cd "${T}"

importpkg dev-libs/boost:1.81 dev-libs/libevent sys-libs/db:4.8

doconf --with-boost-libdir="/pkg/main/dev-libs.boost.libs/lib$LIB_SUFFIX" --enable-asm --without-qtdbus --without-qrencode --enable-wallet --with-daemon --disable-bench --without-libs --without-gui --without-rapidcheck --disable-fuzz --disable-ccache --disable-static --with-system-libsecp256k1 --with-system-univalue
#--with-miniupnpc --enable-upnp-default --enable-zmq --disable-util-cli --disable-util-tx --disable-util-wallet

make -j"$NPROC"
make install DESTDIR="${D}"

finalize
