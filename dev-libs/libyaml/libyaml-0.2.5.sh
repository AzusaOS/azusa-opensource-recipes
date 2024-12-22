#!/bin/sh
source "../../common/init.sh"

get https://github.com/yaml/libyaml/archive/${PV}/libyaml-dist-${PV}.tar.gz
acheck

cd "${S}"

#./bootstrap
aautoreconf

cd "${T}"

doconf --disable-static

make
make install DESTDIR="${D}"

finalize
