#!/bin/sh
source "../../common/init.sh"

get https://github.com/libunwind/libunwind/releases/download/v${PV/_rc/-rc}/${P/_rc/-rc}.tar.gz
acheck

echo "Compiling ${P} ..."
cd "${T}"

importpkg zlib app-arch/xz

# configure & build
doconf --enable-cxx-exceptions --enable-coredump --enable-ptrace --enable-setjmp --enable-zlibdebuginfo --enable-minidebuginfo --enable-debug-frame

make
make install DESTDIR="${D}"

finalize
