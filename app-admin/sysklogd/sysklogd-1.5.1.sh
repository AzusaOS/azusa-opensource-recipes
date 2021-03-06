#!/bin/sh
source "../../common/init.sh"

get http://www.infodrom.org/projects/sysklogd/download/${P}.tar.gz

sed -i '/Error loading kernel symbols/{n;n;d}' ${P}/ksym_mod.c
sed -i 's/union wait/int/' ${P}/syslogd.c

cd "${P}"

make 

mkdir -p "${D}/pkg/main/${PKG}.core.${PVRF}/sbin" "${D}/pkg/main/${PKG}.doc.${PVRF}/man"/man{5,8}
make install BINDIR="${D}/pkg/main/${PKG}.core.${PVRF}/sbin" MANDIR="${D}/pkg/main/${PKG}.doc.${PVRF}/man" MAN_USER=`id -u` MAN_GROUP=`id -g`

finalize
