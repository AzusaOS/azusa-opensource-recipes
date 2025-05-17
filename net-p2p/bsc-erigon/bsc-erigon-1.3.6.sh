#!/bin/sh
source "../../common/init.sh"

# hardcoded revision
fetchgit https://github.com/node-real/bsc-erigon.git "v${PV}"

envcheck
# do not use acheck so we keep networking

export PATH="/pkg/main/dev-lang.go.dev/bin:$PATH"
export GOBIN="${D}/pkg/main/${PKG}.core.${PVRF}/bin"
mkdir -pv "$GOBIN"

cd "${S}"
make erigon
make integration
make install

mv -v ./build/dist/erigon "${D}/pkg/main/${PKG}.core.${PVRF}/bin"
mkdir -pv "${D}/pkg/main/${PKG}.core.${PVRF}/libexec"
mv -v ./build/bin/integration "${D}/pkg/main/${PKG}.core.${PVRF}/libexec"
mv -v ./build/dist/libsilkworm_capi.so "${D}/pkg/main/${PKG}.core.${PVRF}/libexec"
patchelf --add-rpath '$ORIGIN/../libexec' "${D}/pkg/main/${PKG}.core.${PVRF}/bin/erigon"

finalize
