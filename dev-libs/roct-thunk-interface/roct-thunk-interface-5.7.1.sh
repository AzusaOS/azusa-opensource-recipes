#!/bin/sh
source "../../common/init.sh"

get https://github.com/RadeonOpenCompute/ROCT-Thunk-Interface/archive/rocm-${PV}.tar.gz ${P}.tar.gz
acheck

cd "${T}"

importpkg sys-process/numactl

docmake -DBUILD_SHARED_LIBS=YES

finalize
