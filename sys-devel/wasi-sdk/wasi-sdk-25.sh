#!/bin/sh
source "../../common/init.sh"

fetchgit https://github.com/WebAssembly/wasi-sdk.git "wasi-sdk-${PV}"
envcheck

# fatal: detected dubious ownership in repository at '/build/wasi-sdk-25/work/wasi-sdk-wasi-sdk-25/src/wasi-libc'
git config --global --add safe.directory "${S}/src/wasi-libc"

cd "${T}"

mkdir toolchain sysroot
cmake -G Ninja -B toolchain -S "${S}" -DWASI_SDK_BUILD_TOOLCHAIN=ON -DCMAKE_INSTALL_PREFIX=/pkg/main/${PKG}.data.${PVRF}
cmake --build toolchain --target install

cmake -G Ninja -B sysroot -S "${S}" -DCMAKE_INSTALL_PREFIX=/pkg/main/${PKG}.data.${PVRF} -DCMAKE_TOOLCHAIN_FILE=/pkg/main/${PKG}.data.${PVRF}/share/cmake/wasi-sdk.cmake -DCMAKE_C_COMPILER_WORKS=ON -DCMAKE_CXX_COMPILER_WORKS=ON
cmake --build sysroot --target install

echo "Moving tree..."
mkdir -p "${D}/pkg/main"
mv /pkg/main/${PKG}.data.${PVRF} "${D}/pkg/main/${PKG}.data.${PVRF}"

fixelf
archive
