#!/bin/bash
source "../../common/init.sh"

get https://download.qt.io/official_releases/qt/${PV%.*}/${PV}/single/qt-everywhere-src-${PV}.tar.xz
acheck

cd "${S}"

apatch "$FILESDIR/${P}"-*.patch
importpkg libevent

# bug 620444 - ensure local headers are used
# + adding importpkg headers too
find "${S}/qtwebengine" -type f -name "*.pr[fio]" | xargs sed -i -e 's|INCLUDEPATH += |&$$QTWEBENGINE_ROOT/include '"${CPPFLAGS}"' |' || die

# fix missing qt_version_tag symbol w/ LTO, bug 674382
sed -i -e 's/^gcc:ltcg/gcc/' "${S}/qtbase/src/corelib/global/global.pri"

# alter $S/qtbase/mkspecs/common/gcc-base.conf
# add: eval(QMAKE_CFLAGS_RELEASE += $$(CPPFLAGS))
# add: eval(QMAKE_LFLAGS_RELEASE += $$(LDFLAGS))
cat >>"$S/qtbase/mkspecs/common/gcc-base.conf" <<EOF
eval(QMAKE_CFLAGS_RELEASE += \$\$(CPPFLAGS))
eval(QMAKE_CXXFLAGS_RELEASE += \$\$(CPPFLAGS))
eval(QMAKE_LFLAGS_RELEASE += \$\$(LDFLAGS))
EOF

export CFLAGS="${CPPFLAGS} -O2"
export CXXFLAGS="${CPPFLAGS} -O2"

# fix libevent include because Qt provides no way to pass CPPFLAGS to chromium
# and will not honor WEBENGINE_LIBEVENT_PREFIX either, or same for X11, etc
#mv /pkg/main/sys-libs.glibc.dev/include /pkg/main/sys-libs.glibc.dev/include.orig
#ln -snfT /pkg/main/azusa.symlinks.core/full/include /pkg/main/sys-libs.glibc.dev/include
#rsync -a --force /pkg/main/sys-libs.glibc.dev/include.orig/ /pkg/main/azusa.symlinks.core/full/include/
rsync --ignore-existing -a /pkg/main/azusa.symlinks.core/full/include/ /pkg/main/sys-libs.glibc.dev/include/
rsync --ignore-existing -a /pkg/main/azusa.symlinks.core/full/lib$LIB_SUFFIX/ /pkg/main/sys-libs.glibc.dev/lib$LIB_SUFFIX/

cd "${T}"

# https://doc.qt.io/qt-5/configure-options.html
CONFIGURE=(
	-prefix "/pkg/main/${PKG}.core.${PVRF}"
	-headerdir "/pkg/main/${PKG}.dev.${PVRF}/include"
	-libdir "/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX"
	-plugindir "/pkg/main/${PKG}.libs.${PVRF}/plugins"
	-docdir "/pkg/main/${PKG}.libs.${PVRF}/doc"
	-examplesdir "/pkg/main/${PKG}.doc.${PVRF}/examples"
	-no-compile-examples

	-platform linux-g++
	-no-feature-statx # gentoo bug 672856
	-opensource
	-confirm-license
	-release
	-shared

	-pkg-config
	-glib
	-icu
	-ssl
	-openssl-linked
	-dbus-linked

	# Third-Party Libraries
	-system-zlib
	-system-libjpeg
	-system-libpng
	-system-xcb
	-system-freetype
	-system-pcre
	-system-harfbuzz
	-system-doubleconversion # thirdparty
	-system-sqlite # db

	# webengine
	-webengine-alsa
	-webengine-pulseaudio
	-system-webengine-icu
	-system-webengine-opus # TODO: add opus to system then change this
	-system-webengine-webp # TODO
	-system-webengine-ffmpeg
	-webengine-pepper-plugins
	-webengine-printing-and-pdf
	-webengine-webrtc

	# required for -gtk
	-L/pkg/main/sys-libs.zlib.libs/lib$LIB_SUFFIX
	-L/pkg/main/x11-libs.libX11.libs/lib$LIB_SUFFIX
	-L/pkg/main/x11-libs.libXext.libs/lib$LIB_SUFFIX

	# required for qtmultimedia:
	# /pkg/main/media-libs.gst-plugins-base.core.1.16.2.linux.amd64/include/gstreamer-1.0/gst/gl/wayland/gstgldisplay_wayland.h:26:10: fatal error: wayland-client.h: No such file or directory
	-I/pkg/main/dev-libs.wayland.dev/include

	# libs, etc: qtbase
	DBUS_PREFIX=/pkg/main/sys-apps.dbus.dev
	LIBUDEV_PREFIX=/pkg/main/sys-fs.udev.dev
	ZLIB_PREFIX=/pkg/main/sys-libs.zlib.dev
	ZSTD_PREFIX=/pkg/main/app-arch.zstd.dev
	DOUBLECONVERSION_PREFIX=/pkg/main/dev-libs.double-conversion.dev
	ICU_PREFIX=/pkg/main/dev-libs.icu.dev
	PCRE2_PREFIX=/pkg/main/dev-libs.libpcre2.dev
	OPENSSL_PREFIX=/pkg/main/dev-libs.openssl.dev

	# gui
	HARFBUZZ_PREFIX=/pkg/main/media-libs.harfbuzz.dev
	# LIBMD4C_PREFIX
	# OpenVG → mesa?
	OPENGL_PREFIX=/pkg/main/media-libs.mesa.dev # ?
	# vulkan
	LIBINPUT_PREFIX=/pkg/main/dev-libs.libinput.dev
	# TSLIB_PREFIX → x11-libs/tslib
	XCB_PREFIX=/pkg/main/x11-libs.libxcb.dev

	# sqldrivers
	MYSQL_PREFIX=/pkg/main/dev-db.mariadb.dev

	ALSA_PREFIX=/pkg/main/media-libs.alsa-lib.dev

	# WEBENGINE_RE2_PREFIX → dev-libs/re2
	WEBENGINE_OPUS_PREFIX=/pkg/main/media-libs.opus.dev
	WEBENGINE_FFMPEG_PREFIX=/pkg/main/media-video.ffmpeg.dev
	WEBENGINE_SNAPPY_PREFIX=/pkg/main/app-arch.snappy.dev
	WEBENGINE_LIBEVENT_PREFIX=/pkg/main/dev-libs.libevent.dev
)

callconf "${CONFIGURE[@]}" | tee configure.log

# trick to make errors shown in red in make
make -j"$NPROC" || /bin/bash -i
#	2> >(while IFS='' read -r line; do echo -e "\e[01;31m$line\e[0m" >&2; done)
make install DESTDIR="${D}"

mkdir -p "${D}/pkg/main"
mv /.pkg-main-rw/${PKG}.* "${D}/pkg/main"

organize

echo "TODO → split Qt into per-module files"

archive
