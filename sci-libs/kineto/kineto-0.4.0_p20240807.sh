#!/bin/sh
source "../../common/init.sh"

CommitId=d9753139d181b9ff42872465aac0e5d3018be415

get https://github.com/pytorch/${PN}/archive/${CommitId}.tar.gz "${P}.tar.gz"
acheck

S="${S}/libkineto"

cd "${S}"

apatch "${FILESDIR}"/${PN}-0.4.0-gcc13.patch \
	"$FILESDIR/kineto-0.4.0_p20231031-gentoo.patch"

importpkg dev-libs/libfmt dev-libs/dynolog

docmake -DBUILD_SHARED_LIBS=YES -DKINETO_BUILD_TESTS=OFF -DLIBKINETO_NOXPUPTI=Yes #-DCUDA_SOURCE_DIR=/

finalize
