#!/bin/sh
source "../../common/init.sh"
inherit python

CommitId=dbc3157bf256f1339b3fa1fef2be89ac4078be0e

get https://github.com/pytorch/${PN}/archive/${CommitId}.tar.gz "${P}.tar.gz"
acheck

# for caffe2 linking, use gcc13
GCC_VERSION=13
export PATH="/pkg/main/sys-devel.gcc.core.$GCC_VERSION/bin:$PATH"
rm -f /usr/bin/gcc /usr/bin/g++

importpkg dev-libs/asmjit dev-libs/cpuinfo dev-cpp/gtest

cd "${S}"

apatch "$FILESDIR/$P-gentoo.patch"

sed -i -e "/-Werror/d" CMakeLists.txt

cd "${T}"

export CPPFLAGS="${CPPFLAGS} -fPIC"

docmake -DBUILD_SHARED_LIBS=YES

finalize
