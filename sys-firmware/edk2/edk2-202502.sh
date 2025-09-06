#!/bin/sh
source "../../common/init.sh"

DBXDATE="05092023" # MMDDYYYY
BUNDLED_BROTLI_SUBMODULE_SHA="f4153a09f87cbb9c826d8fc12c74642bb2d879ea"
BUNDLED_LIBFDT_SUBMODULE_SHA="cfff805481bdea27f900c32698171286542b8d3c"
BUNDLED_LIBSPDM_SUBMODULE_SHA="98ef964e1e9a0c39c7efb67143d3a13a819432e0"
BUNDLED_MBEDTLS_SUBMODULE_SHA="8c89224991adff88d53cd380f42a2baa36f91454"
BUNDLED_MIPI_SYS_T_SUBMODULE_SHA="370b5944c046bab043dd8b133727b2135af7747a"
BUNDLED_OPENSSL_SUBMODULE_P="openssl-3.4.1"

get https://github.com/tianocore/${PN}/archive/${PN}-stable${PV}.tar.gz "${P}.tar.gz"
get https://github.com/google/brotli/archive/${BUNDLED_BROTLI_SUBMODULE_SHA}.tar.gz "brotli-${BUNDLED_BROTLI_SUBMODULE_SHA}.tar.gz"
get https://github.com/DMTF/libspdm/archive/${BUNDLED_LIBSPDM_SUBMODULE_SHA}.tar.gz "libspdm-${BUNDLED_LIBSPDM_SUBMODULE_SHA}.tar.gz"
get https://github.com/Mbed-TLS/mbedtls/archive/${BUNDLED_MBEDTLS_SUBMODULE_SHA}.tar.gz "mbedtls-${BUNDLED_MBEDTLS_SUBMODULE_SHA}.tar.gz"
get https://github.com/MIPI-Alliance/public-mipi-sys-t/archive/${BUNDLED_MIPI_SYS_T_SUBMODULE_SHA}.tar.gz "mipi-sys-t-${BUNDLED_MIPI_SYS_T_SUBMODULE_SHA}.tar.gz"
get https://github.com/openssl/openssl/releases/download/${BUNDLED_OPENSSL_SUBMODULE_P}/${BUNDLED_OPENSSL_SUBMODULE_P}.tar.gz

# amd64
get "https://uefi.org/sites/default/files/resources/x64_DBXUpdate_${DBXDATE}.bin"
get "https://uefi.org/sites/default/files/resources/x64_DBXUpdate.bin" "x64_DBXUpdate_${DBXDATE}.bin"

# arm64
get "https://uefi.org/sites/default/files/resources/arm64_DBXUpdate_${DBXDATE}.bin"
get "https://uefi.org/sites/default/files/resources/arm64_DBXUpdate.bin" "arm64_DBXUpdate_${DBXDATE}.bin"
get "https://github.com/devicetree-org/pylibfdt/archive/${BUNDLED_LIBFDT_SUBMODULE_SHA}.tar.gz" "pylibfdt-${BUNDLED_LIBFDT_SUBMODULE_SHA}.tar.gz"

acheck

# prepare stuff
cd "${S}"
ln -snfv "${WORKDIR}/brotli-${BUNDLED_BROTLI_SUBMODULE_SHA}" BaseTools/Source/C/BrotliCompress/brotli
ln -snfv "${WORKDIR}/brotli-${BUNDLED_BROTLI_SUBMODULE_SHA}" MdeModulePkg/Library/BrotliCustomDecompressLib/brotli
ln -snfv "${WORKDIR}/libspdm-${BUNDLED_LIBSPDM_SUBMODULE_SHA}" SecurityPkg/DeviceSecurity/SpdmLib/libspdm
ln -snfv "${WORKDIR}/mbedtls-${BUNDLED_MBEDTLS_SUBMODULE_SHA}" CryptoPkg/Library/MbedTlsLib/mbedtls
ln -snfv "${WORKDIR}/public-mipi-sys-t-${BUNDLED_MIPI_SYS_T_SUBMODULE_SHA}" MdePkg/Library/MipiSysTLib/mipisyst
ln -snfv "${WORKDIR}/${BUNDLED_OPENSSL_SUBMODULE_P}" CryptoPkg/Library/OpensslLib/openssl
ln -snfv "${WORKDIR}/pylibfdt-${BUNDLED_LIBFDT_SUBMODULE_SHA}" MdePkg/Library/BaseFdtLib/libfdt

cd "${T}"

importpkg zlib

doconf

make
make install DESTDIR="${D}"

finalize
