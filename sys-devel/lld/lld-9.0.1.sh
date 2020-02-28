#!/bin/sh
source "../../common/init.sh"

get https://github.com/llvm/llvm-project/releases/download/llvmorg-${PV}/${P}.src.tar.xz
acheck

cd "${T}"

# see http://llvm.org/docs/CMake.html

# make it possible to run llvm tools within a non-azusa linux (TEMP)
export LLVM_DIR=/pkg/main/sys-devel.llvm.dev.${PV}/lib64/cmake/llvm

cmake ${CHPATH}/${P}.src -DCMAKE_INSTALL_PREFIX=/pkg/main/${PKG}.core.${PVR} -DLLVM_ENABLE_TERMINFO=ON \
	-DLLVM_ENABLE_EH=ON -DLLVM_ENABLE_RTTI=ON \
	-DLLVM_LINK_LLVM_DYLIB=ON

#cmake --build .
make
make install DESTDIR="${D}"

cd "${D}"

finalize