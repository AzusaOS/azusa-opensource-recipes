#!/bin/sh
source "../../common/init.sh"

get https://github.com/axiomatic-systems/Bento4/archive/refs/tags/v1.6.0-641.tar.gz "${P}.tar.gz"
acheck

cd "${T}"

docmake

finalize
