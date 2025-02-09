#!/bin/sh
source "../../common/init.sh"

fetchgit https://github.com/erigontech/silkworm.git capi-${PV}

envcheck
# TODO find way to resolve conan deps or use system
# dev-cpp/abseil-cpp TODO find which version works

importpkg dev-libs/libgit2

export PATH="/pkg/main/dev-python.conan.mod/bin:$PATH"

cd "${T}"
docmake

finalize
