#!/bin/sh
source "../../common/init.sh"

fetchgit https://github.com/WebAssembly/wasi-sdk.git "wasi-sdk-${PV}"
envcheck

cd "${T}"

mkdir toolchain sysroot
cmake -G Ninja -B toolchain -S "${S}" -DWASI_SDK_BUILD_TOOLCHAIN=ON -DCMAKE_INSTALL_PREFIX=/pkg/main/${PKG}.data.${PVRF}
cmake --build toolchain --target install

cmake -G Ninja -B sysroot -S "${S}" -DCMAKE_INSTALL_PREFIX=/pkg/main/${PKG}.data.${PVRF} -DCMAKE_TOOLCHAIN_FILE=/pkg/main/${PKG}.data.${PVRF}/share/cmake/wasi-sdk.cmake -DCMAKE_C_COMPILER_WORKS=ON -DCMAKE_CXX_COMPILER_WORKS=ON
cmake --build sysroot --target install

finalize
