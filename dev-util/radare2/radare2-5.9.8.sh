#!/bin/sh
source "../../common/init.sh"

#BINS_COMMIT=87ab82cc96e83e02f044c0c4111ade2a65576c60

get https://github.com/radareorg/radare2/archive/${PV}.tar.gz "${P}.tar.gz"
eval $(cat "${S}/libr/arch/p/arm/v35/Makefile" | grep '^ARCH_ARM')
get https://github.com/radareorg/vector35-arch-arm64/archive/${ARCH_ARM64_COMMIT}.tar.gz "${PN}-vector35-arm64-${ARCH_ARM64_COMMIT:0:7}.tar.gz"
get https://github.com/radareorg/vector35-arch-armv7/archive/${ARCH_ARMV7_COMMIT}.tar.gz "${PN}-vector35-armv7-${ARCH_ARMV7_COMMIT:0:7}.tar.gz"

cd "${S}"
apatch "$FILESDIR/radare2-5.8.2-vector35.patch"
mv "${WORKDIR}/vector35-arch-arm64-${ARCH_ARM64_COMMIT}" libr/arch/p/arm/v35/arch-arm64
mv "${WORKDIR}/vector35-arch-armv7-${ARCH_ARMV7_COMMIT}" libr/arch/p/arm/v35/arch-armv7
acheck

cd "${T}"

importpkg zlib dev-libs/xxhash dev-libs/capstone

domeson -Duse_sys_capstone=true

finalize
