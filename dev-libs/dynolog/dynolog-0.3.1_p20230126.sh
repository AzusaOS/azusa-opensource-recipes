#!/bin/sh
source "../../common/init.sh"
inherit cmake

CommitId=d9753139d181b9ff42872465aac0e5d3018be415

get https://github.com/pytorch/${PN}/archive/${CommitId}.tar.gz "${P}.tar.gz"

PATCHES=(
	"${FILESDIR}"/${P}-gcc13.patch
	"${FILESDIR}"/${P}-unbundling.patch
	"${FILESDIR}"/${P}-noWerror.patch
	"${FILESDIR}"/${P}-riscv.patch
	"${FILESDIR}"/${P}-musl.patch
	"${FILESDIR}"/${P}-libcxx.patch
	"${FILESDIR}"/${P}-gcc15.patch
)

cd "${S}"
apatch "${PATCHES[@]}"

cmake_comment_add_subdirectory third_party/gflags
cmake_comment_add_subdirectory third_party/glog
cmake_comment_add_subdirectory third_party/pfs
rm -r third_party/googletest
rm -r third_party/pfs

mkdir "${S}/cmake"
cp -v "$FILESDIR/FindUnwind.cmake" "${S}/cmake"
sed -i -e '2a list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")' CMakeLists.txt

envcheck

cd "${T}"

importpkg sys-libs/libunwind dev-cpp/glog dev-cpp/gtest dev-libs/pfs

docmake -DBUILD_SHARED_LIBS=OFF -DCPR_FORCE_USE_SYSTEM_CURL=ON

cd "${S}"
mkdir -p "${D}/pkg/main/${PKG}.dev.${PVRF}/include/dynolog/src/ipcfabric"
cp dynolog/src/ipcfabric/FabricManager.h "${D}/pkg/main/${PKG}.dev.${PVRF}/include/dynolog/src/ipcfabric"
find dynolog -name '*.h' | xargs install -t "${D}/pkg/main/${PKG}.dev.${PVRF}/include" -D -v

cd "${S}/cli"
cargo build --release
install -D -v target/release/dyno "${D}/pkg/main/${PKG}.core.${PVRF}/bin"
install -D -v "${T}/dynolog/src/dynolog" "${D}/pkg/main/${PKG}.core.${PVRF}/bin"

finalize
