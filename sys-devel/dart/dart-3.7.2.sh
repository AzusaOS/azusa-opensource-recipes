#!/bin/sh
source "../../common/init.sh"

envcheck
#fetchgit https://dart.googlesource.com/sdk.git "$PV"
#acheck

cd "${T}"

# this is not efficient, but google's depot_tools have limitations
fetch dart
cd sdk
git checkout tags/${PV}
gclient sync -D

./tools/build.py --mode release --arch x64 create_sdk

mkdir -p "${D}/pkg/main"
mv -v out/ReleaseX64/dart-sdk "${D}/pkg/main/${PKG}.dev.${PVRF}"

archive
