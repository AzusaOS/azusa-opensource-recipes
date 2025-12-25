#!/bin/sh
source "../../common/init.sh"

fetchgit https://github.com/monero-project/monero.git "v${PV}"
acheck

cd "${T}"

importpkg libunbound dev-libs/boost net-libs/miniupnpc net-libs/zeromq dev-libs/libsodium

docmake -DBUILD_TESTS=ON -DMANUAL_SUBMODULES=1

finalize
