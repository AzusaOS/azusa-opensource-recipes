#!/bin/sh
source "../../common/init.sh"

get https://github.com/tesseract-ocr/${PN}/archive/${PV}.tar.gz ${P}.tar.gz
acheck

cd "${T}"

importpkg media-libs/leptonica

docmake

finalize
