#!/bin/sh
source "../../common/init.sh"

get https://www.kernel.org/pub/software/utils/${PN}/${P}.tar.xz
acheck

cd "${T}"

importpkg dev-util/valgrind

domeson

finalize
