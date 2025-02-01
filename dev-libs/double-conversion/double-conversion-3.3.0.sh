#!/bin/sh
source "../../common/init.sh"

get https://github.com/google/${PN}/archive/v${PV}.tar.gz
acheck

cd "${T}"

docmake -DBUILD_SHARED_LIBS=YES

finalize
