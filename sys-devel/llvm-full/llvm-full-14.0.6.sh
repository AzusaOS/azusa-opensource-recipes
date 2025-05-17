#!/bin/sh
source "../../common/init.sh"
inherit llvm

llvmget _llvm
acheck

cd "${S}/.."

apatch "$FILESDIR/llvm-toolchain-override.patch"

cd "${T}"

importpkg libxml-2.0 icu-uc sci-mathematics/z3 zlib sys-libs/llvm-libunwind sys-libs/libcxx sys-libs/libcxxabi app-arch/xz sys-libs/ncurses dev-lang/lua sys-libs/libxcrypt /pkg/main/sys-devel.llvm-bootstrap.data

# Ensure libraries are available from bootstrap for unwinding
export LIBRARY_PATH="${LIBRARY_PATH}:/pkg/main/sys-devel.llvm-bootstrap.data.${PV}/lib$LIB_SUFFIX/$CHOST"
# -- Could NOT find CursesAndPanel (missing: CURSES_INCLUDE_DIRS CURSES_LIBRARIES PANEL_LIBRARIES) 
# -- Could NOT find Lua (missing: LUA_LIBRARIES LUA_INCLUDE_DIR) (Required is exact version "5.3")

# update to use libs from bootstrap to avoid:
# /usr/bin/ld: /pkg/main/sys-libs.glibc.dev.linux.amd64/pkg/main/sys-libs.libcxxabi.libs.16.0.2.linux.amd64/lib64/libc++abi.so.1: error adding symbols: DSO missing from command line

# Testing the c++ compiler:
# echo -e '#include <iostream>\nint main() { std::cout << "hello world" << std::endl; return 0; }' | /pkg/main/sys-devel.llvm-full.data/bin/clang++ -x c++ -o test -

# importpkg will set CPPFLAGS but that's not read by llvm
export CFLAGS="${CPPFLAGS} -fPIC"
export CXXFLAGS="${CPPFLAGS} -fPIC"

# Create symbolic links to make sure libgcc_s is found during build
mkdir -p "${T}/lib$LIB_SUFFIX"
ln -sf /pkg/main/sys-devel.gcc.libs/lib$LIB_SUFFIX/libgcc_s.so "${T}/lib$LIB_SUFFIX/libgcc_s.so"
ln -sf /pkg/main/sys-devel.gcc.libs/lib$LIB_SUFFIX/libgcc_s.so.1 "${T}/lib$LIB_SUFFIX/libgcc_s.so.1"

# Add library paths for finding libgcc_s
export LIBRARY_PATH="${LIBRARY_PATH}:/pkg/main/sys-devel.llvm-bootstrap.data.${PV}/lib$LIB_SUFFIX/$CHOST:/pkg/main/sys-devel.gcc.libs/lib$LIB_SUFFIX:${T}/lib$LIB_SUFFIX"
export LDFLAGS="${LDFLAGS} -L/pkg/main/sys-devel.llvm-bootstrap.data.${PV}/lib$LIB_SUFFIX/$CHOST -L/pkg/main/sys-devel.gcc.libs/lib$LIB_SUFFIX -lgcc_s"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/pkg/main/sys-devel.gcc.libs/lib$LIB_SUFFIX:${T}/lib$LIB_SUFFIX"

# make sure previous config doesn't cause issues
rm -fr /pkg/main/${PKG}.data.${PVRF}/config

# https://llvm.org/docs/CMake.html

CMAKE_OPTS=(
	-DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;compiler-rt;lld;lldb;mlir;openmp;polly"
	-DLLVM_TARGETS_TO_BUILD=all
	-DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi"
	-DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=ON
	-DLLVM_ENABLE_ASSERTIONS=ON
	-DLLVM_ENABLE_EH=ON
	-DLLVM_ENABLE_RTTI=ON
	-DLLVM_BUILD_EXAMPLES=OFF
	-DLLVM_INCLUDE_TESTS=OFF
	-DLLVM_BUILD_TESTS=OFF
	-DLLVM_INCLUDE_DOCS=ON
	-DLLVM_ENABLE_DOXYGEN=OFF
	-DLLVM_ENABLE_SPHINX=ON
	
	# Specify libraries for runtime linking
	-DLIBCXX_CXX_ABI="libcxxabi"
	-DLIBCXX_CXX_ABI_INCLUDE_PATHS="/pkg/main/sys-devel.llvm-bootstrap.data.${PV}/include/c++/v1"
	-DCMAKE_EXE_LINKER_FLAGS="-L/pkg/main/sys-devel.gcc.libs/lib$LIB_SUFFIX -lgcc_s"
	-DCMAKE_SHARED_LINKER_FLAGS="-L/pkg/main/sys-devel.gcc.libs/lib$LIB_SUFFIX -lgcc_s"

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

	# Runtime library configuration
	-DLIBCXXABI_USE_LLVM_UNWINDER=OFF
	
	# Simplify compiler-rt build
	-DLLVM_ENABLE_LIBCXX=ON
	-DCOMPILER_RT_BUILD_BUILTINS=OFF
	-DCOMPILER_RT_BUILD_SANITIZERS=OFF
	-DCOMPILER_RT_BUILD_XRAY=OFF
	-DCOMPILER_RT_BUILD_LIBFUZZER=OFF
	-DCOMPILER_RT_BUILD_PROFILE=OFF
	
	# Use libgcc for runtime support
	-DLIBCXX_USE_COMPILER_RT=OFF
	-DLIBCXXABI_USE_COMPILER_RT=OFF
	-DLIBCXX_HAS_GCC_S_LIB=ON
	-DLIBCXXABI_HAS_GCC_S_LIB=ON
	
	# Exception handling settings
	-DLIBCXX_ENABLE_EXCEPTIONS=ON
	-DLIBCXXABI_ENABLE_EXCEPTIONS=ON
	-DLIBCXX_ENABLE_RTTI=ON
	-DLIBCXXABI_ENABLE_RTTI=ON
	
	# Build modes
	-DLIBCXX_ENABLE_SHARED=ON
	-DLIBCXX_ENABLE_STATIC=ON
	-DLIBCXXABI_ENABLE_SHARED=ON
	-DLIBCXXABI_ENABLE_STATIC=ON
	
	# Don't build extras to simplify the build
	-DLIBCXX_INCLUDE_BENCHMARKS=OFF
	-DLIBCXXABI_INCLUDE_TESTS=OFF
	
	# Make sure correct paths are used
	-DLIBCXX_LIBDIR_SUFFIX="${LIB_SUFFIX}"
	-DLIBCXXABI_LIBDIR_SUFFIX="${LIB_SUFFIX}"

	-DPython3_EXECUTABLE=/bin/python3
	-DLLDB_PYTHON_EXE_RELATIVE_PATH=../dev-lang.python.core/bin/

	# force llvm defaults - use libgcc as unwinder
	-DCLANG_DEFAULT_CXX_STDLIB="libc++"
	-DCLANG_DEFAULT_RTLIB="libgcc"
	-DCLANG_DEFAULT_UNWINDLIB="libgcc"
	-DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=OFF
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
--unwindlib=libgcc
-fPIC
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
