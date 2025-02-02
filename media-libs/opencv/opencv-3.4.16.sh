#!/bin/sh
source "../../common/init.sh"

get https://github.com/opencv/${PN}/archive/${PV}.tar.gz
acheck

# remove -Werror=address since it fails with recent gcc
sed -i -e '/Werror=address/d' "${S}/cmake/OpenCVCompilerOptions.cmake"

cd "${T}"

docmake -DBUILD_SHARED_LIBS=ON -DOPENCV_GENERATE_PKGCONFIG=YES -DCMAKE_CXX_FLAGS="-Wno-error=address"

finalize
