#!/bin/sh
source "../../common/init.sh"

get https://github.com/htacg/tidy-html5/archive/${PV}/${P}.tar.gz
acheck

cd "${T}"

docmake -DBUILD_SHARED_LIBS=YES -DBUILD_TAB2SPACE=ON

install -v -m755 tab2space "${D}/pkg/main/${PKG}.core.${PVRF}/bin"

finalize
