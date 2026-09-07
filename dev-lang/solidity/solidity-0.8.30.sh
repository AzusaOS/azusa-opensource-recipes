#!/bin/sh
source "../../common/init.sh"

fetchgit https://github.com/ethereum/solidity.git "v${PV}"
acheck

cd "${S}"

# configure for release version
git rev-parse HEAD >commit_hash.txt
echo -n >prerelease.txt

# force SOVERSION on libs to ensure a given solc uses the right libs
for foo in evmasm langutil smtutil libsolc solidity solutil yul; do
	if [ -d lib$foo ]; then
		echo "set_target_properties($foo PROPERTIES VERSION $PV SOVERSION $PV)" >>lib$foo/CMakeLists.txt
	else
		echo "set_target_properties($foo PROPERTIES VERSION $PV SOVERSION $PV)" >>$foo/CMakeLists.txt
	fi
done
echo "set_target_properties(phaser PROPERTIES VERSION $PV SOVERSION $PV)" >>tools/CMakeLists.txt
echo "set_target_properties(solcli PROPERTIES VERSION $PV SOVERSION $PV)" >>solc/CMakeLists.txt

# boost >= 1.91 no longer ships a compiled libboost_system (header-only since
# 1.69), so find_package(Boost COMPONENTS ... system) fails. Drop it, as
# upstream did later (0.8.36 no longer lists it).
sed -i -e 's/;system"/"/' cmake/EthDependencies.cmake
sed -i -e 's/ Boost::system//' libsolutil/CMakeLists.txt

# 0.8.31+ sets CMP0167 NEW, which only looks for BoostConfig.cmake; our boost
# package ships none, so keep using the classic FindBoost module.
sed -i -e 's/cmake_policy(SET CMP0167 NEW)/cmake_policy(SET CMP0167 OLD)/' cmake/EthDependencies.cmake

# boost >= 1.88 defaults to Boost.Process v2; select the v1 API (as upstream
# does since 0.8.30+) for the files that spawn SMT solvers.
for f in $(grep -rl '#include <boost/process.hpp>' lib* solc tools); do
	sed -i -e 's@#include <boost/process.hpp>@#define BOOST_PROCESS_VERSION 1\n#include <boost/process/v1/child.hpp>\n#include <boost/process/v1/io.hpp>\n#include <boost/process/v1/pipe.hpp>\n#include <boost/process/v1/search_path.hpp>@' "$f"
done

cd "${T}"

# ensure solidity can find z3
importpkg sci-mathematics/z3

CMAKEOPTS=(
	-DTESTS=OFF
	-DBUILD_SHARED_LIBS=ON
	-DSTRICT_Z3_VERSION=OFF
	# gcc 15 trips -Werror=maybe-uninitialized (false positive) in libevmasm/Inliner.cpp
	-DPEDANTIC=OFF

	-DBoost_ROOT=/pkg/main/dev-libs.boost.dev
	-DBoost_NO_WARN_NEW_VERSIONS=1
	-DBoost_USE_STATIC_LIBS=OFF
)

docmake "${CMAKEOPTS[@]}"

mkdir -p "${D}/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX"
for foo in */*.so.${PV}; do
	cp -v "$foo" "${D}/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX/"
done

finalize
