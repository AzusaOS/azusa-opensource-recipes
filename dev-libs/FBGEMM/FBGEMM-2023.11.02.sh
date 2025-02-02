#!/bin/sh
source "../../common/init.sh"
inherit python

CommitId=dbc3157bf256f1339b3fa1fef2be89ac4078be0e

get https://github.com/pytorch/${PN}/archive/${CommitId}.tar.gz "${P}.tar.gz"
acheck

importpkg dev-libs/asmjit dev-libs/cpuinfo dev-cpp/gtest

cd "${S}"

apatch "$FILESDIR/$P-gentoo.patch"

sed -i -e "/-Werror/d" CMakeLists.txt

cd "${T}"

export CPPFLAGS="${CPPFLAGS} -fPIC"

docmake -DBUILD_SHARED_LIBS=YES

finalize
