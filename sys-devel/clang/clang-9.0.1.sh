#!/bin/sh
source "../../common/init.sh"

get https://github.com/llvm/llvm-project/releases/download/llvmorg-${PV}/${P}.src.tar.xz
acheck

cd "${T}"

# see http://llvm.org/docs/CMake.html

# make it possible to run llvm tools within a non-azusa linux (TEMP)
export LLVM_DIR=/pkg/main/sys-devel.llvm.dev.${PV}/lib64/cmake/llvm

cmake ${CHPATH}/clang-${PV}.src -DCMAKE_INSTALL_PREFIX=/pkg/main/${PKG}.core.${PVR} -DLLVM_ENABLE_TERMINFO=ON \
	-DLLVM_ENABLE_LIBXML2=ON -DLLVM_ENABLE_EH=ON -DLLVM_ENABLE_RTTI=ON -DLLVM_APPEND_VC_REV=OFF -DWITH_POLLY=OFF -DLLVM_INSTALL_UTILS=ON \
	-DLLVM_BUILD_LLVM_DYLIB=ON -DLLVM_LINK_LLVM_DYLIB=ON -DCMAKE_CXX_STANDARD_LIBRARIES="-ldl" \
	-DLLVM_ENABLE_FFI=ON -DFFI_INCLUDE_DIR=/pkg/main/dev-libs.libffi.dev/include -DFFI_LIBRARY_DIR=/pkg/main/dev-libs.libffi.libs/lib$LIB_SUFFIX

make -j"$NPROC"
make install DESTDIR="${D}"

#cmake -DCMAKE_INSTALL_PREFIX="${D}/pkg/main/${PKG}.dev.${PVR}" -P cmake_install.cmake

finalize
