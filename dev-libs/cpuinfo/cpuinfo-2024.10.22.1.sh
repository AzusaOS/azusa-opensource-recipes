#!/bin/sh
source "../../common/init.sh"

CommitId=094fc30b9256f54dad5ad23bcbfb5de74781422f
get https://github.com/pytorch/${PN}/archive/${CommitId}.tar.gz "${P}.tar.gz"
acheck

cd "${S}"

PATCHES=(
	"${FILESDIR}"/${PN}-2023.11.04-gentoo.patch
	"${FILESDIR}"/${PN}-2023.01.13-test.patch
)

apatch "${PATCHES[@]}"

cd "${T}"

docmake -DBUILD_SHARED_LIBS=YES -DCPUINFO_BUILD_BENCHMARKS=OFF -DCPUINFO_BUILD_UNIT_TESTS=OFF

finalize
