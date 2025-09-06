#!/bin/sh
source "../../common/init.sh"

get https://github.com/harfbuzz/harfbuzz/releases/download/${PV}/${P}.tar.xz
acheck

cd "${T}"

domeson

finalize
