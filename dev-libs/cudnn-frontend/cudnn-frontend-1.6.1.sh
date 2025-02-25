#!/bin/sh
source "../../common/init.sh"

get https://github.com/NVIDIA/cudnn-frontend/archive/refs/tags/v${PV}.tar.gz "${P}.tar.gz"
acheck

cd "${T}"

docmake -DCUDNN_FRONTEND_BUILD_UNIT_TESTS=OFF -DCUDNN_FRONTEND_BUILD_SAMPLES=OFF

finalize
