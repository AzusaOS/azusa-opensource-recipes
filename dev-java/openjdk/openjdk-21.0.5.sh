#!/bin/sh
source "../../common/init.sh"

get https://github.com/openjdk/jdk21u/archive/jdk-${PV}-ga.tar.gz

BOOT_JDK="/pkg/main/dev-java.openjdk.core"

if [ -f "$BOOT_JDK/bin/java" ]; then
	VERSION="$("$BOOT_JDK/bin/java" --version | head -n1 | awk '{ print $2 }')" # 15.0.2
	case $VERSION in
		20*|21*)
			# good
			:
			;;
		*)
			# probably too old
			echo "boot JDK is too old"
			exit 1
			;;
	esac
fi

if [ ! -d "$BOOT_JDK" ]; then
	# grab LFS bootjdk
	echo "Previous JDK not found or too old"
	exit 1
fi

# grab tests
cd "${S}"
get https://anduin.linuxfromscratch.org/BLFS/OpenJDK/OpenJDK-21.0.2/jtreg-7.3.1+1.tar.gz
acheck

export CPPFLAGS="${CPPFLAGS} -fno-stack-protector"

unset JAVA_HOME
importpkg x11 libjpeg media-libs/giflib zlib lcms2

# avoid openjdk erronously including pipewire from full/include
rm -fr /pkg/main/azusa.symlinks.core/full/include/spa /pkg/main/azusa.symlinks.core/full/include/pipewire

bash configure --enable-unlimited-crypto \
	--disable-warnings-as-errors \
	--disable-ccache \
	--disable-precompiled-headers \
	--enable-full-docs=no \
	--with-stdc++lib=dynamic \
	--with-freetype=system \
	--with-harfbuzz=system \
	--with-giflib=system \
	--with-jtreg=$PWD/jtreg \
	--with-lcms=system \
	--with-libjpeg=system \
	--with-libpng=system \
	--with-zlib=system \
	--with-version-build="10" \
	--with-version-pre="" \
	--with-version-opt="" \
	--with-boot-jdk="$BOOT_JDK" \
	--with-vendor-name="Azusa" \
	--with-vendor-url="https://www.azusa.jp" \
	--with-vendor-version-string="${PVR}" \
	--enable-headless-only=no \
	--x-includes="/pkg/main/azusa.symlinks.core/full/include" \
	--x-libraries="/pkg/main/azusa.symlinks.core/full/lib$LIB_SUFFIX" \
	--with-cups-include="/pkg/main/net-print.cups.dev/include" \
	--with-fontconfig-include="/pkg/main/media-libs.fontconfig.dev/include" \
	--with-extra-cflags="$CPPFLAGS" --with-extra-cxxflags="$CPPFLAGS" --with-extra-ldflags="$LDFLAGS"
	#--enable-jvm-feature-dtrace=yes \
#	--x-includes="/pkg/main/x11-libs.libX11.dev/include"
#	--x-libraries="/pkg/main/x11-libs.libX11.dev/lib$LIB_SUFFIX"
#	--with-cacerts-file=/etc/pki/tls/java/cacerts

make images

#export JT_JAVA=$(echo $PWD/build/*/jdk)
#jtreg/bin/jtreg -jdk:$JT_JAVA -automatic -ignore:quiet -v1 \
#    test/jdk:tier1 test/langtools:tier1
#unset JT_JAVA

mkdir -p "${D}/pkg/main/${PKG}.core.${PVRF}"
cp -Rv build/*/images/jdk/* "${D}/pkg/main/${PKG}.core.${PVRF}"
#chown -R root:root "${D}/pkg/main/${PKG}.core.${PVRF}"
for s in 16 24 32 48; do
	install -vDm644 src/java.desktop/unix/classes/sun/awt/X11/java-icon${s}.png "${D}/pkg/main/${PKG}.core.${PVRF}/share/icons/hicolor/${s}x${s}/apps/java.png"
done

fixelf
archive
