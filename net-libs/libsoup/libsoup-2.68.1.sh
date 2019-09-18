#!/bin/sh
source "../../common/init.sh"

get http://ftp.gnome.org/pub/gnome/sources/libsoup/2.68/${P}.tar.xz

cd "${T}"

export VAPIGEN=vapigen-0.40
export VALAC=valac-0.40

meson --prefix="/pkg/main/${PKG}.core.${PVR}" -Dvapi=enabled -Dgssapi=disabled "${CHPATH}/${P}"

ninja
DESTDIR="${D}" ninja install

finalize