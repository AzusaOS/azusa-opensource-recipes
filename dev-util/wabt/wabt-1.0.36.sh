#!/bin/sh
source "../../common/init.sh"

# use fetchgit to also get submodules
fetchgit https://github.com/WebAssembly/wabt.git "${PV}"
acheck

cd "${T}"

docmake -DBUILD_TESTS=OFF

finalize
