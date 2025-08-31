#!/bin/sh
source "../../common/init.sh"

get https://github.com/google/googletest/releases/download/v${PV}/googletest-${PV}.tar.gz
acheck

cd "${T}"

docmake

finalize
