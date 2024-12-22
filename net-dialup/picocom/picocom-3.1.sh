#!/bin/sh
source "../../common/init.sh"

get https://github.com/npat-efault/${PN}/archive/${PV}.tar.gz ${P}.tar.gz
acheck

cd "${S}"

make LDFLAGS="${LDFLAGS}" CFLAGS="${CFLAGS} ${CPPFLAGS} -Wall"

dobin picocom pc{asc,xm,ym,zm}
doman picocom.1
dodoc CHANGES.old CONTRIBUTORS README.md

finalize
