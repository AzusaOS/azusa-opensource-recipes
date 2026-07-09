#!/bin/sh
source "../../common/init.sh"

get https://github.com/projectatomic/${PN}/releases/download/v${PV}/${P}.tar.xz
acheck

cd "${T}"

importpkg sys-libs/libcap

# gcc 15 constprop reports false-positive null %s args in bubblewrap.c's
# die()/die_with_mount_error() calls; relax that one warning from -Werror.
export CPPFLAGS="$CPPFLAGS -Wno-error=format-overflow"

domeson -Dman=disabled

finalize
