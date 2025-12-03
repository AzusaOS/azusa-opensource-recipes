#!/bin/sh
source "../../common/init.sh"

get https://github.com/plougher/squashfs-tools/archive/${PV}.tar.gz
acheck

cd "${P}/squashfs-tools"

importpkg zlib dev-libs/lzo app-arch/lz4 app-arch/xz app-arch/zstd

make
make install INSTALL_DIR="${D}/pkg/main/${PKG}.core.${PVRF}/bin"

# make sure we use the new mksquashfs binary
export PATH="${D}/pkg/main/${PKG}.core.${PVRF}/bin:$PATH"

finalize
