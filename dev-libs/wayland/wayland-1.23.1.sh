#!/bin/sh
source "../../common/init.sh"

get https://wayland.freedesktop.org/releases/${P}.tar.xz
acheck

cd "${T}"

# scanner is in wayland-scanner
domeson -Dlibraries=true -Dscanner=false

finalize
