#!/bin/sh
source "../../common/init.sh"

get https://github.com/ngtcp2/ngtcp2/releases/download/v${PV}/${P}.tar.xz
acheck

cd "${T}"

docmake -DENABLE_GNUTLS=ON -DENABLE_OPENSSL=OFF

finalize
