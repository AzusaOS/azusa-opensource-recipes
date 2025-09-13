#!/bin/sh
source "../../common/init.sh"

get http://ftp.gnome.org/pub/gnome/sources/${PN}/${PV%.*}/${P}.tar.xz
acheck

importpkg dev-libs/libelf dev-libs/libffi

cd "${T}"

# TODO: eventially enable doc once we have docbook

# configure & build
# -Dintrospection=disabled might be needed to build glib for building gobject-introspection
domeson --strip --default-library shared -Dselinux=disabled #-Dintrospection=disabled

finalize
