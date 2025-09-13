#!/bin/sh
source "../../common/init.sh"

get https://gitlab.freedesktop.org/wayland/wayland/-/releases/${PV}/downloads/wayland-${PV}.tar.xz
acheck

cd "${T}"

# scanner *only*
domeson -Ddocumentation=false -Ddtd_validation=false -Dlibraries=false -Dscanner=true -Dtests=false

finalize
