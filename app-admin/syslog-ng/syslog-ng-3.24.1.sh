#!/bin/sh
source "../../common/init.sh"

get https://github.com/balabit/syslog-ng/releases/download/${P}/${P}.tar.gz
acheck

cd "${T}"

importpkg json-c

doconf --sysconfdir=/etc/syslog-ng --disable-java

make
make install DESTDIR="${D}"

finalize
