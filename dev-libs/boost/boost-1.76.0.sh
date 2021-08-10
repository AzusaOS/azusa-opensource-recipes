#!/bin/sh
source "../../common/init.sh"

get https://boostorg.jfrog.io/artifactory/main/release/${PV}/source/boost_${PV//./_}.tar.bz2
acheck

importpkg dev-libs/icu zlib app-arch/bzip2 app-arch/xz app-arch/zstd

BOOST_BUILD_PATH="${CHPATH}/boost_${PV//./_}"
BOOST_PYTHON="3.9"

cd "$BOOST_BUILD_PATH"

export CPPFLAGS="$CPPFLAGS -I/pkg/main/dev-lang.python.core.${BOOST_PYTHON}/include/python${BOOST_PYTHON}"

# configure & build
./bootstrap.sh --with-icu=/pkg/main/dev-libs.icu.core --with-python="python${BOOST_PYTHON}" --with-python-root="/pkg/main/dev-lang.python.core.${BOOST_PYTHON}/" --with-python-version="${BOOST_PYTHON}" --prefix="/pkg/main/${PKG}.core.${PVRF}" --libdir="/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX" --includedir="/pkg/main/${PKG}.dev.${PVRF}/include"

# create user-config.jam
cat >>user-config.jam <<EOF
using gcc : $(gcc -dumpversion) : /bin/gcc : <cflags>"${CFLAGS}" <cxxflags>"${CPPFLAGS} ${CXXFLAGS}" <linkflags>"${CPPFLAGS} ${LDFLAGS} -lstdc++" ;
using mpi ;
using python : ${BOOST_PYTHON} : python${BOOST_PYTHON} : /pkg/main/dev-lang.python.core.${BOOST_PYTHON}/include/python${BOOST_PYTHON} : /pkg/main/dev-lang.python.libs.${BOOST_PYTHON}/lib$LIB_SUFFIX ;
EOF

#ICU_PATH="/pkg/main/dev-libs.icu.core"
#ICU_LINK="$(pkg-config --libs icu-uc)"

B2_OPTS=(
	-q -d+2
	--ignore-site-config
	-sICU_PATH="/pkg/main/dev-libs.icu.dev"
	--user-config="${BOOST_BUILD_PATH}/user-config.jam"
	--without-stacktrace
	--layout=system
	--no-cmake-config
	cxxflags="$CPPFLAGS -std=c++14"
	library-path="/pkg/main/dev-libs.icu.libs/lib$LIB_SUFFIX"
	threading=multi
	link=shared
)

./b2 "${B2_OPTS[@]}" stage -j"$NPROC"
./b2 "${B2_OPTS[@]}" install --prefix="${D}/pkg/main/${PKG}.core.${PVRF}" --libdir="${D}/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX" --includedir="${D}/pkg/main/${PKG}.dev.${PVRF}/include"

finalize
