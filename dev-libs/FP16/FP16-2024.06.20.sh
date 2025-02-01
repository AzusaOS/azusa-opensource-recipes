#!/bin/sh
source "../../common/init.sh"
inherit python

CommitId=98b0a46bce017382a6351a19577ec43a715b6835

get https://github.com/Maratyszcza/${PN}/archive/${CommitId}.tar.gz ${P}.tar.gz
acheck

importpkg dev-libs/psimd

cd "${S}"

apatch "$FILESDIR/$P-gentoo.patch"

cd "${T}"

importpkg zlib

docmake -DBUILD_SHARED_LIBS=YES -DFP16_BUILD_BENCHMARKS=OFF -DFP16_BUILD_TESTS=OFF

finalize
