#!/bin/sh
source "../../common/init.sh"

get https://download.sourceforge.net/${PN}/${P}.tar.gz
acheck

cd "${P}"

apatch \
	"${FILESDIR}/${P}-windows.patch" \
	"${FILESDIR}/${P}-glibc.patch"

sed -i \
	-e '/^Encoding/d' \
	-e '/^Icon/s/\.png//' \
	-e '/^Categories/s/Application;//' \
	gqview.desktop
mv configure.in configure.ac

#autoreconf --force --install --verbose
glib-gettextize --copy --force
aclocal
autoconf --force
autoheader
automake --add-missing --copy --force-missing
libtoolize

doconf

make
make install DESTDIR="${D}"

finalize
