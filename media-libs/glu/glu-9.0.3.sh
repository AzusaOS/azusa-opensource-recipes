#!/bin/sh
source "../../common/init.sh"

get https://mesa.freedesktop.org/archive/glu/${P}.tar.xz
acheck

cd "${T}"

domeson

finalize
