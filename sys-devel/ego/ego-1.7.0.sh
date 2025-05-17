#!/bin/sh
source "../../common/init.sh"

get https://github.com/edgelesssys/ego/archive/refs/tags/v${PV}.tar.gz ${P}.tar.gz
envcheck

cd "${S}"
rm -fr _ertgo
ln -snfv /pkg/main/sys-devel.edgelessrt-bin.dev/go _ertgo

cd "${T}"

source /pkg/main/dev-libs.sgx-sdk-bin.dev/environment
source /pkg/main/sys-devel.edgelessrt-bin.dev/share/openenclave/openenclaverc
importpkg dev-libs/sgx-dcap
export PATH="/pkg/main/sys-devel.edgelessrt-bin.dev/go/bin:$PATH"

# ego build file is not compatible with ninja because of wildcards
CMAKE_BUILD_ENGINE="Unix Makefiles" docmake || /bin/bash -i

archive
