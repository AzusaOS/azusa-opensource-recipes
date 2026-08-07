#!/bin/sh
source "../../common/init.sh"

# jdk8u tag for this update (PV 8.0.502 -> update 502, build b07)
JDK8U_TAG="jdk8u502-b07"

get https://github.com/openjdk/jdk8u/archive/refs/tags/${JDK8U_TAG}.tar.gz ${P}.tar.gz

# JDK 8 must be bootstrapped with a JDK 7 (or 8). azusa has neither an 8 nor a 7,
# so fetch a prebuilt JDK 7 to boot from.
cd "${T}"
get https://cdn.azul.com/zulu/bin/zulu7.56.0.11-ca-jdk7.0.352-linux_x64.tar.gz
BOOT_JDK="${T}/zulu7.56.0.11-ca-jdk7.0.352-linux_x64"

acheck

cd "${S}"

# JDK 8's hotspot/native code does not build with gcc 15; use gcc 10 (the oldest
# gcc available). PATH-prepend rather than switchgcc (which writes to /pkg/main).
export PATH="/pkg/main/sys-devel.gcc.core.10/bin:$PATH"

# hotspot hard-codes -Werror (make/linux/makefiles/gcc.make); a newer gcc emits
# new warnings that would abort the build - drop it.
sed -i -e 's/^WARNINGS_ARE_ERRORS = -Werror/WARNINGS_ARE_ERRORS =/' \
	hotspot/make/linux/makefiles/gcc.make

unset JAVA_HOME
importpkg x11 zlib media-libs/giflib media-libs/freetype media-libs/alsa-lib

# gcc 10+ defaults to -fno-common; JDK 8-era native code relies on common symbols
export CPPFLAGS="${CPPFLAGS} -fcommon -fno-stack-protector"

bash configure \
	--enable-unlimited-crypto \
	--with-milestone=fcs \
	--with-update-version="$(ver_cut 3)" \
	--with-build-number="${JDK8U_TAG##*-}" \
	--with-boot-jdk="$BOOT_JDK" \
	--with-stdc++lib=dynamic \
	--with-zlib=system \
	--with-giflib=system \
	--with-freetype-include="/pkg/main/media-libs.freetype.dev/include/freetype2" \
	--with-freetype-lib="/pkg/main/media-libs.freetype.libs/lib$LIB_SUFFIX" \
	--with-alsa-include="/pkg/main/media-libs.alsa-lib.dev/include" \
	--with-alsa-lib="/pkg/main/media-libs.alsa-lib.libs/lib$LIB_SUFFIX" \
	--with-cups-include="/pkg/main/net-print.cups.dev/include" \
	--with-fontconfig-include="/pkg/main/media-libs.fontconfig.dev/include" \
	--x-includes="/pkg/main/azusa.symlinks.core/full/include" \
	--x-libraries="/pkg/main/azusa.symlinks.core/full/lib$LIB_SUFFIX" \
	--with-extra-cflags="$CPPFLAGS" --with-extra-cxxflags="$CPPFLAGS" --with-extra-ldflags="$LDFLAGS"

make images

mkdir -p "${D}/pkg/main/${PKG}.core.${PVRF}"
cp -Rv build/*/images/j2sdk-image/* "${D}/pkg/main/${PKG}.core.${PVRF}"

fixelf
archive
