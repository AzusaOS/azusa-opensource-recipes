#!/bin/sh
source "../../common/init.sh"

fetchgit https://github.com/hyle-team/zano.git "${PV}"
acheck

cd "${S}"

# src/currency_core/genesis.h:15:5: error: ‘uint64_t’ does not name a type
# src/currency_core/genesis.h:9:1: note: ‘uint64_t’ is defined in header ‘<cstdint>’; did you forget to ‘#include <cstdint>’?
sed -i -e '/#include <string>/a #include <cstdint>' src/currency_core/genesis.h src/wallet/plain_wallet_api.h

# libmdbx's mdbx_memory_barrier() guards a clang-only __c11_atomic_thread_fence
# builtin with __has_extension(c_atomic). gcc 14+ now implements __has_extension
# and answers yes, but has no such builtin -> implicit-declaration error. Require
# __clang__ so gcc falls through to __atomic_thread_fence instead.
sed -i -e 's@#if __has_extension(c_atomic) || __has_extension(cxx_atomic)@#if (__has_extension(c_atomic) || __has_extension(cxx_atomic)) \&\& defined(__clang__)@' \
	contrib/db/libmdbx/src/elements/osal.h

cd "${T}"

importpkg dev-libs/boost:1.81 dev-libs/libevent sys-libs/db:4.8 sys-libs/libbacktrace

export BOOST_ROOT=/pkg/main/dev-libs.boost.dev.1.81

# boost 1.81's cstdfloat specializes std::numeric_limits<__float128>, which
# clashes with gcc 15's libstdc++ (which now provides it) -> "redefinition"
# error. BOOST_MATH_DISABLE_FLOAT128 does NOT help: config.hpp defines
# BOOST_MATH_USE_FLOAT128 via the BOOST_HAS_FLOAT128 branch, which ignores it.
# BOOST_CSTDFLOAT_NO_LIBQUADMATH_SUPPORT is checked directly in the offending
# guards, so it disables boost's float128 numeric_limits; zano only uses
# cpp_int, not float128, so nothing else needs it.
# (Newer boost fixes this but ships no BoostConfig.cmake here and drops the
# compiled boost_system lib that zano's find_package requires.)
export CPPFLAGS="$CPPFLAGS -DBOOST_CSTDFLOAT_NO_LIBQUADMATH_SUPPORT"

CMAKE_TARGET_ALL=daemon CMAKE_EXTRA_TARGETS=simplewallet CMAKE_TARGET_INSTALL=skip docmake

# install src/zanod src/simplewallet
install -v -D -t "${D}/pkg/main/${PKG}.core.${PVRF}/bin" src/zanod src/simplewallet

finalize
