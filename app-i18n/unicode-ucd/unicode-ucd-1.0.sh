#!/bin/sh
source "../../common/init.sh"

mkdir -p "${D}/pkg/main/${PKG}.core.${PVR}/share/unicode/ucd"
cd "${D}/pkg/main/${PKG}.core.${PVR}/share/unicode/ucd"

get https://www.unicode.org/Public/UNIDATA/UCD.zip
rm -f UCD.zip

archive