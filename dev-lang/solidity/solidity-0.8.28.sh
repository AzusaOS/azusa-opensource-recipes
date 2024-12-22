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

cd "${T}"

# ensure solidity can find z3
importpkg sci-mathematics/z3

CMAKEOPTS=(
	-DTESTS=OFF
	-DBUILD_SHARED_LIBS=ON
	-DSTRICT_Z3_VERSION=OFF

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
