#!/bin/sh
source "../../common/init.sh"

get https://github.com/axboe/${PN}/archive/refs/tags/${P}.tar.gz
acheck

cd "${S}"

doconflight

make
make install DESTDIR="${D}"

finalize
