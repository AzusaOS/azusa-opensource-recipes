#!/bin/sh
source "../../common/init.sh"

get https://github.com/ocaml/ocamlbuild/archive/refs/tags/${PV}.tar.gz "${P}.tar.gz"
acheck

cd "${S}"

make configure OCAMLBUILD_PREFIX="/pkg/main/${PKG}.core.${PVRF}" OCAMLBUILD_BINDIR="/pkg/main/${PKG}.core.${PVRF}/bin" OCAMLBUILD_LIBDIR="/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX"
make
make install DESTDIR="${D}"

finalize
