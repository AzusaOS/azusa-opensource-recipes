#!/bin/sh
source "../../common/init.sh"

get https://github.com/notofonts/notofonts.github.io/archive/${COMMIT}.tar.gz ${P}.tar.gz
#acheck

cd "${S}"

mkdir -p "${D}/pkg/main/${PKG}.fonts.${PVRF}"
mv -v fonts/*/hinted/ttf/*.tt[fc] "${D}/pkg/main/${PKG}.fonts.${PVRF}"

finalize
