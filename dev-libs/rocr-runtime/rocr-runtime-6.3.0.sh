#!/bin/sh
source "../../common/init.sh"

get https://github.com/RadeonOpenCompute/ROCR-Runtime/archive/rocm-${PV}.tar.gz "${P}.tar.gz"
acheck

cd "${T}"

importpkg dev-libs/libelf zlib sys-process/numactl sys-devel/llvm-full

docmake -DBUILD_SHARED_LIBS=YES

finalize
