#!/bin/sh
source "../../common/init.sh"

get https://download.litecoin.org/${P}/src/${P}.tar.gz
acheck

cd "${S}"

apatch \
	"$FILESDIR/litecoin-0.21.3_boost_copy_options.patch" \
	"$FILESDIR/litecoin-0.21.3_boost_directory_iterator.patch" \
	"$FILESDIR/litecoin-0.21.3_secp256k1_extrakeys_fix.patch" \
	"$FILESDIR/litecoin-0.21.5.5_boost_system_header_only.patch"

aautoreconf

# Boost::System is header-only since Boost 1.69 and the stub library
# is gone in 1.89. Defensive fixup in case the m4 patch did not propagate
# into the generated configure (e.g. when aclocal pulled the system copy).
sed -i 's|as_fn_error \$? "Could not find a version of the Boost::System library!".*|:|' configure

cd "${T}"

importpkg dev-libs/boost dev-libs/libevent sys-libs/db:4.8 libcrypto dev-libs/libfmt

doconf --with-boost-libdir="/pkg/main/dev-libs.boost.libs/lib$LIB_SUFFIX" --enable-asm --without-qtdbus --without-qrencode --enable-wallet --with-daemon --disable-bench --without-libs --without-gui --disable-shared --with-pic --disable-tests --disable-gui-tests
#--enable-asm --without-qtdbus --without-qrencode --enable-wallet --with-daemon --disable-bench --without-libs --without-gui --without-rapidcheck --disable-fuzz --disable-ccache --with-system-univalue
#--with-system-libsecp256k1 --with-system-libsecp256k1-libdir="/pkg/main/dev-libs.libsecp256k1.libs/lib$LIB_SUFFIX"
#--with-miniupnpc --enable-upnp-default --enable-zmq --disable-util-cli --disable-util-tx --disable-util-wallet

make #-j"$NPROC"
make install DESTDIR="${D}"

finalize
