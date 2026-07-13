#!/bin/sh
source "../../common/init.sh"

fetchgit https://github.com/hyle-team/zano.git "${PV}"
acheck

inherit gcc
switchgcc 13

cd "${S}"

# src/currency_core/genesis.h:15:5: error: ‘uint64_t’ does not name a type
# src/currency_core/genesis.h:9:1: note: ‘uint64_t’ is defined in header ‘<cstdint>’; did you forget to ‘#include <cstdint>’?
sed -i -e '/#include <string>/a #include <cstdint>' src/currency_core/genesis.h src/wallet/plain_wallet_api.h

cd "${T}"

importpkg dev-libs/boost:1.81 dev-libs/libevent sys-libs/db:4.8

export BOOST_ROOT=/pkg/main/dev-libs.boost.dev.1.81

CMAKE_TARGET_ALL=daemon CMAKE_EXTRA_TARGETS=simplewallet CMAKE_TARGET_INSTALL=skip docmake

# install src/zanod src/simplewallet
install -v -D -t "${D}/pkg/main/${PKG}.core.${PVRF}/bin" src/zanod src/simplewallet

finalize
