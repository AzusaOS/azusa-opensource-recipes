#!/bin/sh
source "../../common/init.sh"

fetchgit https://github.com/edgelesssys/edgelessrt.git "v${PV}"
# SHA256=4764b8ce858579d99f1b66bb1e5f04ba149a38aea15649fff19f65f8d9113fd0
get https://raw.githubusercontent.com/torvalds/linux/v5.13/arch/x86/include/uapi/asm/sgx.h "sgx-4764b8c.h"
# TODO openenclave downloads stuff from the internet :(
envcheck

export CXXFLAGS="${CXXFLAGS} --stdlib=libstdc++"
export CPPFLAGS="${CPPFLAGS} --stdlib=libstdc++"

cd "${S}"

# fix openenclave build
cp /pkg/main/dev-libs.openssl.core/etc/ssl/*.* /etc/ssl
#sed -i '9i -DCRYPTO_LIB=/pkg/main/dev-libs.openssl.libs/lib64/libcrypto.so' 3rdparty/openenclave/CMakeLists.txt
#sed -i '9i -DDL_LIB=/pkg/main/sys-libs.glibc.libs/lib64/libdl.so.2' 3rdparty/openenclave/CMakeLists.txt
sed -i '9i -DLIB_SUFFIX=' 3rdparty/openenclave/CMakeLists.txt
grep -rn 'find_library(CRYPTO_LIB NAMES crypto)' | cut -d: -f1 | xargs sed -i -e 's#find_library(CRYPTO_LIB NAMES crypto)#find_library(CRYPTO_LIB NAMES crypto PATHS /pkg/main/dev-libs.openssl.libs/lib64)#'
grep -rn 'find_library(DL_LIB NAMES dl)' . | cut -d: -f1 | xargs sed -i -e 's#find_library(DL_LIB NAMES dl)#find_library(DL_LIB NAMES dl PATHS /pkg/main/sys-libs.glibc.libs/lib64)#'

find . -name CMakeLists.txt -o -name compiler_settings.cmake | xargs sed -i -e 's/-Werror=strict-aliasing//;s/-Werror//'

sed -i '7i #include <sstream>' 3rdparty/ttls/src/test_instances.cc

cd "${T}"

export DART_ROOT=/pkg/main/sys-devel.dart.dev
if [ ! -f /bin/arch ]; then
	echo -e '#!/bin/sh\nuname -m' >/bin/arch
	chmod +x /bin/arch
fi

. /pkg/main/dev-libs.sgx-sdk-bin.dev/environment
importpkg dev-libs/openssl /pkg/main/sys-devel.llvm-bootstrap.data.11 dev-libs/sgx-dcap

# force llvm 11

CLANG_PATH="/pkg/main/sys-devel.llvm-bootstrap.data.11"
# force stdc++ in config
echo '--gcc-toolchain=/pkg/main/' >> "$CLANG_PATH/config/clang-common.cfg"
echo '--stdlib=libstdc++' >"$CLANG_PATH/config/clang-cxx.cfg"
export PATH="/pkg/main/sys-devel.dart.dev/bin:${CLANG_PATH}/bin:$PATH"
export CC="${CLANG_PATH}/bin/clang"
export CXX="${CLANG_PATH}/bin/clang++"
rm -f /bin/clang /bin/clang++ /bin/go

# fix lib path if libsuffix isn't ''
sed -i -e 's#openenclave-install/lib/openenclave#openenclave-install/lib64/openenclave#' "${S}/src/CMakeLists.txt"

# do not use docmake since we want everything in dev
# for example "lib64" dir name for libs isn't supported
cmake -GNinja "${S}" -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX="/pkg/main/${PKG}.dev.${PVRF}"
ninja -j1 || /bin/bash -i
OE_SIMULATION=1 ctest
DESTDIR="${D}" ninja -j1 install
#docmake

# fix path in lib64/openenclave/cmake/openenclave-targets.cmake
# contains: set(_IMPORT_PREFIX "/build/edgelessrt-0.4.9/temp/3rdparty/openenclave/openenclave-install")
# contains: set(_IMPORT_PREFIX "/build/edgelessrt-0.4.9/temp/ertcore-install")
echo "Fixing dir paths..."
find "${D}" -name '*.cmake' -o -name '*.pc'
find "${D}" -name '*.cmake' -o -name '*.pc' | xargs sed -i -e "s#${T}/3rdparty/openenclave/openenclave-install#/pkg/main/${PKG}.dev.${PVRF}#"
find "${D}" -name '*.cmake' -o -name '*.pc' | xargs sed -i -e "s#${T}/ertcore-install#/pkg/main/${PKG}.dev.${PVRF}#"

fixelf
archive
