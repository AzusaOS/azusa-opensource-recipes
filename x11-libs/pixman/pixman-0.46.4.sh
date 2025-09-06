#!/bin/sh
source "../../common/init.sh"

get https://www.cairographics.org/releases/${P}.tar.gz
acheck

cd "${T}"

importpkg zlib

domeson

finalize
