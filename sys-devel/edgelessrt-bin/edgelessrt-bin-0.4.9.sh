#!/bin/sh
source "../../common/init.sh"

get https://github.com/edgelesssys/edgelessrt/releases/download/v${PV}/edgelessrt_${PV}_amd64_ubuntu-24.04.deb
acheck

ar x edgelessrt_${PV}_amd64_ubuntu-24.04.deb
tar xvf data.tar.gz
mkdir -p "${D}/pkg/main"
mv opt/edgelessrt "${D}/pkg/main/${PKG}.dev.${PVRF}"
cd "${D}/pkg/main/${PKG}.dev.${PVRF}"

echo "Fixing folders"
find "." -name '*.cmake' -o -name '*.pc' -o -name 'openenclaverc' | xargs sed -i -e "s#/opt/edgelessrt#/pkg/main/${PKG}.dev.${PVRF}#"

# fix libraries
grep -rn 'find_library(CRYPTO_LIB NAMES crypto)' | cut -d: -f1 | xargs sed -i -e 's#find_library(CRYPTO_LIB NAMES crypto)#find_library(CRYPTO_LIB NAMES crypto PATHS /pkg/main/dev-libs.openssl.libs/lib64)#'
grep -rn 'find_library(DL_LIB NAMES dl)' . | cut -d: -f1 | xargs sed -i -e 's#find_library(DL_LIB NAMES dl)#find_library(DL_LIB NAMES dl PATHS /pkg/main/sys-libs.glibc.libs/lib64)#'

fixelf
archive
