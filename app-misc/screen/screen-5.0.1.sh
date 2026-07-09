#!/bin/sh
source "../../common/init.sh"

get https://ftp.gnu.org/gnu/${PN}/${P}.tar.gz
acheck

cd "${S}"

aautoreconf

#cd "${T}"

importpkg tinfo libxcrypt sys-libs/pam

doconf --enable-socket-dir=/var/run/screen --with-pty-group=5 --with-system_screenrc=/etc/screenrc

sed -i -e "s%/usr/local/etc/screenrc%/etc/screenrc%" {etc,doc}/*

# upstream texinfo bug: an unescaped '@' makes makeinfo read '@opensuse' as a
# command and fail to build screen.info (the address above escapes it as @@).
sed -i -e 's/alexander_naumov@opensuse\.org/alexander_naumov@@opensuse.org/' doc/screen.texinfo

make
make install DESTDIR="${D}"

finalize
