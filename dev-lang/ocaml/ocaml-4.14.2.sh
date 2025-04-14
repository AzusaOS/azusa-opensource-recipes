#!/bin/sh
source "../../common/init.sh"

fetchgit https://github.com/ocaml/ocaml.git "${PV}"
acheck

cd "${S}"

doconf

make
make install DESTDIR="${D}"

finalize
