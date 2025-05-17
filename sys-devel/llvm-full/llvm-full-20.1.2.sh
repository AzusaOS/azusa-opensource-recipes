#!/bin/sh
source "../../common/init.sh"
inherit llvm

llvmget _llvm
acheck

cd "${S}/.."

apatch "$FILESDIR/llvm-toolchain-override.patch"

# See: https://github.com/llvm/llvm-project/pull/84572/files
cat >>clang/tools/clang-fuzzer/dictionary/CMakeLists.txt <<EOF

set_target_properties(clang-fuzzer-dictionary
  PROPERTIES
  LINKER_LANGUAGE CXX
  )
EOF

cd "${T}"

importpkg libxml-2.0 icu-uc sci-mathematics/z3 zlib sys-libs/llvm-libunwind sys-libs/libcxx sys-libs/libcxxabi app-arch/xz sys-libs/ncurses dev-lang/lua /pkg/main/sys-devel.llvm-bootstrap.data.${PV}
# -- Could NOT find CursesAndPanel (missing: CURSES_INCLUDE_DIRS CURSES_LIBRARIES PANEL_LIBRARIES) 
# -- Could NOT find Lua (missing: LUA_LIBRARIES LUA_INCLUDE_DIR) (Required is exact version "5.3")


# Testing the c++ compiler:
# echo -e '#include <iostream>\nint main() { std::cout << "hello world" << std::endl; return 0; }' | /pkg/main/sys-devel.llvm-full.data/bin/clang++ -x c++ -o test -

# importpkg will set CPPFLAGS but that's not read by llvm
export CFLAGS="${CPPFLAGS}"
export CXXFLAGS="${CPPFLAGS}"

# make sure previous config doesn't cause issues
rm -fr /pkg/main/${PKG}.data.${PVRF}/config

# https://llvm.org/docs/CMake.html

CMAKE_OPTS=(
	-DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;compiler-rt;lld;lldb;mlir;openmp;polly;bolt"
	-DLLVM_TARGETS_TO_BUILD=all
	-DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind"
	-DLLVM_ENABLE_ASSERTIONS=ON
	-DLLVM_ENABLE_EH=ON
	-DLLVM_ENABLE_RTTI=ON
	-DLLVM_BUILD_EXAMPLES=OFF
	-DLLVM_INCLUDE_TESTS=OFF
	-DLLVM_BUILD_TESTS=OFF
	-DLLVM_INCLUDE_DOCS=ON
	-DLLVM_ENABLE_DOXYGEN=OFF
	-DLLVM_ENABLE_SPHINX=ON

	# saves a lot of space
	-DLLVM_BUILD_LLVM_DYLIB=ON
	-DLLVM_LINK_LLVM_DYLIB=ON
	-DLLVM_VERSION_SUFFIX=+full

	-DZLIB_LIBRARY=/pkg/main/sys-libs.zlib.libs.${OS}.${ARCH}/lib$LIB_SUFFIX/libz.so
	-DZLIB_INCLUDE_DIR=/pkg/main/sys-libs.zlib.dev.${OS}.${ARCH}/include

	-DLLVM_HOST_TRIPLE="${CHOST}"
	-DLLVM_LIBDIR_SUFFIX=$LIB_SUFFIX

	-DDEFAULT_SYSROOT="/pkg/main/sys-libs.glibc.dev.${OS}.${ARCH}"
	#-DC_INCLUDE_DIRS="/pkg/main/sys-libs.glibc.dev.${OS}.${ARCH}/include"

	-DLIBCXXABI_USE_LLVM_UNWINDER=ON

	-DPython3_EXECUTABLE=/bin/python3
	-DLLDB_PYTHON_EXE_RELATIVE_PATH=../dev-lang.python.core/bin/
	-DLLDB_ENABLE_LUA=OFF # TODO fix lua build

	# force llvm defaults
	-DCLANG_DEFAULT_CXX_STDLIB="libc++"
	-DCLANG_DEFAULT_RTLIB="compiler-rt"
	-DCLANG_DEFAULT_UNWINDLIB="libunwind"
	-DCLANG_CONFIG_FILE_SYSTEM_DIR="/pkg/main/${PKG}.data.${PVRF}/config"
)

# do not use llvmbuild since we are building llvm itself
# do not use docmake either since we want this to be contained in a data dir
#cmake -S "${S}" -B "${T}" -G Ninja -Wno-dev "${CMAKE_OPTS[@]}"
#ninja -j"$NPROC" -v all

mkdir -p "${D}/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX"
mkdir -p "${D}/pkg/main/${PKG}.core.${PVRF}"
ln -snf "${D}/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX" "${D}/pkg/main/${PKG}.core.${PVRF}/lib$LIB_SUFFIX"

if [ x"$LIB_SUFFIX" != x ]; then
	# pre-create a symlink for lib → lib$LIB_SUFFIX
	mkdir -p "${D}/pkg/main/${PKG}.data.${PVRF}/lib$LIB_SUFFIX"
	ln -snf "lib$LIB_SUFFIX" "${D}/pkg/main/${PKG}.data.${PVRF}/lib"
	ln -snf "lib$LIB_SUFFIX" "${D}/pkg/main/${PKG}.core.${PVRF}/lib"
fi

#DESTDIR="${D}" ninja -j"$NPROC" -v install

mkdir -p "${D}/pkg/main/${PKG}.data.${PVRF}/config"
echo "@clang-common.cfg" >"${D}/pkg/main/${PKG}.data.${PVRF}/config/clang.cfg"
echo "@clang-common.cfg" >"${D}/pkg/main/${PKG}.data.${PVRF}/config/clang++.cfg"
echo "@clang-cxx.cfg" >>"${D}/pkg/main/${PKG}.data.${PVRF}/config/clang++.cfg"
echo "@clang-common.cfg" >"${D}/pkg/main/${PKG}.data.${PVRF}/config/clang-cpp.cfg"
echo "@clang-cxx.cfg" >>"${D}/pkg/main/${PKG}.data.${PVRF}/config/clang-cpp.cfg"

cat >"${D}/pkg/main/${PKG}.data.${PVRF}/config/clang-common.cfg" <<EOF
-fuse-ld=lld
EOF

cat >"${D}/pkg/main/${PKG}.data.${PVRF}/config/clang-cxx.cfg" <<EOF
# fix clang include path order
-nostdinc
-isystem /pkg/main/${PKG}.core.${PVRF}/include/c++/v1
-isystem /pkg/main/sys-libs.glibc.dev.linux.amd64/include
-isystem /pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX/clang/${PV/.*}/include
-isystem /pkg/main/${PKG}.core.${PVRF}/include/${CHOST}/c++/v1

# allow finding libc++
-L/pkg/main/${PKG}.data.${PVRF}/lib$LIB_SUFFIX/$CHOST/
EOF

docmake "${CMAKE_OPTS[@]}"

ln -snf "/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX" "${D}/pkg/main/${PKG}.core.${PVRF}/lib$LIB_SUFFIX"

fixelf
archive
