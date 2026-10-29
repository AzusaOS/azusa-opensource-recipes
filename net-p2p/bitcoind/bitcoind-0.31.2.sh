#!/bin/sh
source "../../common/init.sh"

MY_PV=${PV:2}
get https://bitcoincore.org/bin/bitcoin-core-${MY_PV}/bitcoin-${MY_PV}.tar.gz "bitcoin-${PV}.tar.gz"
acheck

sed -i 's/find_package(Boost \([0-9.]*\) REQUIRED CONFIG)/find_package(Boost \1 REQUIRED)/' "${S}/cmake/module/AddBoostIfNeeded.cmake"

cd "${T}"

importpkg dev-libs/boost dev-libs/libevent sqlite3

docmake \
	-DBUILD_DAEMON=ON \
	-DBUILD_CLI=ON \
	-DBUILD_TX=ON \
	-DBUILD_UTIL=ON \
	-DBUILD_WALLET_TOOL=ON \
	-DBUILD_GUI=OFF \
	-DBUILD_BENCH=OFF \
	-DBUILD_TESTS=OFF \
	-DBUILD_FUZZ_BINARY=OFF \
	-DBUILD_KERNEL_LIB=OFF \
	-DENABLE_WALLET=ON \
	-DENABLE_IPC=OFF \
	-DWITH_CCACHE=OFF \
	-DWITH_ZMQ=OFF

finalize
