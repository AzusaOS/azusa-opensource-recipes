#!/bin/sh
source "../../common/init.sh"

get https://gitlab.com/bitcoin-cash-node/bitcoin-cash-node/-/archive/v${PV}/bitcoin-cash-node-v${PV}.tar.bz2
acheck

cd "${S}"

apatch \
	"$FILESDIR/bitcoin-cash-node-27.1.0-gcc14-move.patch"

# fix calls to sub-instance of cmake
sed -i -e "4i -DBoost_ROOT=/pkg/main/dev-libs.boost.dev \\\\" cmake/templates/NativeCmakeRunner.cmake.in
sed -i -e "4i -DZLIB_ROOT=/pkg/main/sys-libs.zlib.dev \\\\" cmake/templates/NativeCmakeRunner.cmake.in
sed -i -e "4i -DEvent_ROOT=/pkg/main/dev-libs.libevent.dev \\\\" cmake/templates/NativeCmakeRunner.cmake.in
sed -i -e "4i -DGMP_ROOT=/pkg/main/dev-libs.gmp.dev \\\\" cmake/templates/NativeCmakeRunner.cmake.in

cd "${T}"

importpkg dev-libs/boost dev-libs/libevent sys-libs/db:5.3 net-libs/miniupnpc net-libs/zeromq dev-libs/gmp net-libs/libnatpmp zlib

docmake -DBUILD_BITCOIN_QT=OFF -DBoost_ROOT=/pkg/main/dev-libs.boost.dev -DCLIENT_VERSION_IS_RELEASE=ON

# rename binaries to differenciate from bitcoin
cd "${D}/pkg/main/${PKG}.core.${PVRF}/bin"
for foo in *; do
	mv -v "$foo" "$(echo "$foo" | sed -e 's/bitcoin/bitcoin-cash/')"
done

finalize
