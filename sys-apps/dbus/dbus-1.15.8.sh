#!/bin/sh
source "../../common/init.sh"

get https://dbus.freedesktop.org/releases/dbus/${P}.tar.xz
acheck

cd "${T}"

importpkg X

domeson

finalize
