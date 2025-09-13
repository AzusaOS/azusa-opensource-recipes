#!/bin/sh
source "../../common/init.sh"

get https://www.gnupg.org/ftp/gcrypt/gnutls/v${PV%.*}/${P}.tar.xz
acheck

cd "${T}"

importpkg dev-libs/gmp dev-libs/libunistring libunbound dev-libs/libtasn1 app-arch/brotli # app-crypt/trousers

doconf --disable-valgrind-tests --disable-rpath --without-included-libtasn1 --with-default-trust-store-file=/pkg/main/app-misc.ca-certificates.core/etc/ssl/certs/ca-certificates.crt --enable-tools
# --with-unbound-root-key-file="${EPREFIX}"/etc/dnssec/root-anchors.txt

make -j"$NPROC"
make install DESTDIR="${D}"

finalize
