#!/bin/sh
source "../../common/init.sh"

MY_P="${PN}-v${PV}"
get https://github.com/yarnpkg/yarn/releases/download/v${PV}/${MY_P}.tar.gz
acheck

npm install --global --prefix "${D}/pkg/main/${PKG}.core.${PVRF}" ${MY_P}.tar.gz

archive
