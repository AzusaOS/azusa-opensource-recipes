#!/bin/sh
source "../../common/init.sh"

UPSTREAM_V="$(ver_cut 1-2)"

get https://github.com/erlang/otp/archive/OTP-${PV}.tar.gz ${P}.tar.gz
get https://github.com/${PN}/otp/releases/download/OTP-${UPSTREAM_V}/otp_doc_man_${UPSTREAM_V}.tar.gz ${PN}_doc_man_${UPSTREAM_V}.tar.gz
get https://github.com/${PN}/otp/releases/download/OTP-${UPSTREAM_V}/otp_doc_html_${UPSTREAM_V}.tar.gz ${PN}_doc_html_${UPSTREAM_V}.tar.gz
acheck

cd "${S}"

importpkg zlib sys-libs/ncurses net-misc/lksctp-tools
setjava

myconf=(
	--disable-builtin-zlib

	# don't search for static zlib
	--with-ssl-zlib=no

	--enable-kernel-poll
	--with-javac
	--with-odbc
	--enable-sctp
	--with-ssl=/pkg/main/dev-libs.openssl.dev
	--enable-dynamic-ssl-lib
	#--with-wx-config=/pkg/main/x11-libs.wxGTK.core/bin/wx-config
	#--with-wxdir=/dev/null
)

doconf "${myconf[@]}"

make -j"$NPROC"
make docs DOC_TARGETS=chunks
make install DESTDIR="${D}"
make INSTALL_PREFIX="${D}" install-docs DOC_TARGETS=chunks

finalize
