#!/bin/sh
source "../../common/init.sh"
inherit libs

fetchgit https://github.com/mono/mono.git "${P}"
acheck

cd "${S}"

preplib
./autogen.sh

doconf --with-x --without-ikvm-native --disable-dtrace --without-xen_opt --with-mcs-docs --enable-nls
# --with-orbis=yes,no --with-unreal=yes,no --with-wasm=yes,no 
# --with-runtime-preset=net_4_x,all,aot,aot_llvm,hybridaot,hybridaot_llvm,fullaot,fullaot_llvm,winaot,winaotinterp,winaot_llvm,winaotinterp_llvm,bitcode,bitcodeinterp,unreal,fullaotinterp,fullaotinterp_llvm

make -j"$NPROC"
make install DESTDIR="${D}"

finalize
