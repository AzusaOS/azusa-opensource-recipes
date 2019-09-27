#!/bin/sh
source "../../common/init.sh"

get http://releases.llvm.org/${PV}/${P}.src.tar.xz
acheck

cd "${T}"

# see http://llvm.org/docs/CMake.html

cmake ${CHPATH}/${P}.src -DCMAKE_INSTALL_PREFIX=/pkg/main/${PKG}.core.${PVR} -DLLVM_ENABLE_TERMINFO=ON \
	-DLLVM_ENABLE_LIBXML2=ON -DLLVM_ENABLE_EH=ON -DLLVM_ENABLE_RTTI=ON -DLLVM_APPEND_VC_REV=OFF -DWITH_POLLY=OFF -DLLVM_INSTALL_UTILS=ON \
	-DLLVM_BUILD_LLVM_DYLIB=ON -DLLVM_LINK_LLVM_DYLIB=ON \
	-DLLVM_ENABLE_FFI=ON -DFFI_INCLUDE_DIR=`realpath /pkg/main/dev-libs.libffi.dev/include` -DFFI_LIBRARY_DIR=`realpath /pkg/main/dev-libs.libffi.libs/lib64`

#cmake --build .
make -j8

cmake -DCMAKE_INSTALL_PREFIX="${D}/pkg/main/${PKG}.core.${PVR}" -P cmake_install.cmake

cd "${D}"

finalize
