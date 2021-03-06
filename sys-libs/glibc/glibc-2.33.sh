#!/bin/sh
source "../../common/init.sh"

# fetch xz, compile, build
get http://ftp.jaist.ac.jp/pub/GNU/libc/${P}.tar.xz
acheck

cd "${T}"

CONFIGURE=(
	--disable-werror
	--enable-kernel=4.14
	--enable-stack-protector=strong
	--enable-stackguard-randomization
	--with-headers=/pkg/main/sys-kernel.linux.dev/include
	--without-cvs
	--disable-werror
	--enable-bind-now
	--with-bugurl=https://github.com/AzusaOS/azusa-opensource-recipes/issues
	--with-pkgversion="AZUSA ${PVRF}"
	--enable-crypt
#	--enable-systemtap
	--enable-nscd
	--disable-timezone-tools
	libc_cv_slibdir=/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX
)

if [ "$ARCH" == "amd64" ]; then
	CONFIGURE+=(--enable-cet)
fi

# configure & build
doconf "${CONFIGURE[@]}"

make -j"$NPROC"
make install DESTDIR="${D}"

# compatibility libraries for the NIS/NIS+ support, do not need .so or .a, only .so.X (gentoo)
find "${D}" -name "libnsl.a" -delete
find "${D}" -name "libnsl.so" -delete

# With devpts under Linux mounted properly, we do not need the pt_chown suid bit (gentoo)
find "${D}" -name pt_chown -exec chmod -s {} +

# generate share/i18n/SUPPORTED (Debian-style locale updating)
mkdir -pv "${D}/pkg/main/${PKG}.core.${PVRF}/share/i18n"
sed -e "/^#/d" -e "/SUPPORTED-LOCALES=/d" -e "s: \\\\::g" -e "s:/: :g" "${S}"/localedata/SUPPORTED > "${D}/pkg/main/${PKG}.core.${PVRF}/share/i18n/SUPPORTED"

locale_list=`echo "C.UTF-8 UTF-8"; cat "${D}/pkg/main/${PKG}.core.${PVRF}/share/i18n/SUPPORTED"`

mkdir -p "${D}/pkg/main/${PKG}.data.locale.${PVRF}"

# we create this link temporarily this way so we can grab the generated files in the right location
ln -snfT "${D}/pkg/main/${PKG}.data.locale.${PVRF}" "${D}/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX/locale"

# install "C" locale
cp -vT "${FILESDIR}/C-locale" "${D}/pkg/main/${PKG}.core.${PVRF}/share/i18n/locales/C"

# generate locales
mkdir -p "${D}$(realpath /pkg/main/sys-libs.glibc.libs)/lib64/locale"
OIFS="$IFS"
IFS=$'\n'
for foo in $locale_list; do
	locale=`echo "$foo" | cut -f1 -d' '`
	charset=`echo "$foo" | cut -f2 -d' '`
	locale_short=${locale%%.*}
	echo " * Generating locale $locale_short ($charset)"
	localedef -c --no-archive -i "${D}/pkg/main/${PKG}.core.${PVRF}/share/i18n/locales/$locale_short" -f "$charset" -A "${D}/pkg/main/${PKG}.core.${PVRF}/share/locale/locale.alias" --prefix "${D}" "${locale}" || /bin/bash
done
IFS="$OIFS"
# cleanup
rm -fr "${D}$(realpath /pkg/main/sys-libs.glibc.libs)"

# generate locale archive
for foo in "${D}/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX/locale"/*/; do
	localedef --add-to-archive "${foo%/}" --replace --prefix "${D}" && rm -fr "${foo%/}"
done

# fix link to point to symlinks, this way we can generate locale-archive with other i18n paths
ln -snfT "/pkg/main/${PKG}.data.locale.${PVRF}" "${D}/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX/locale"

# make dev a sysroot for gcc
ln -snfTv "/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX" "${D}/pkg/main/${PKG}.dev.${PVRF}/lib$LIB_SUFFIX"
if [ x"$LIB_SUFFIX" != x ]; then
	ln -snfTv "lib$LIB_SUFFIX" "${D}/pkg/main/${PKG}.dev.${PVRF}/lib"
fi
ln -snfTv . "${D}/pkg/main/${PKG}.dev.${PVRF}/usr"

# linux includes
for foo in /pkg/main/sys-kernel.linux.dev/include/*; do
	BASE=`basename "$foo"`
	if [ -d "${D}/pkg/main/${PKG}.dev.${PVRF}/include/$BASE" ]; then
		# already a dir there, need to do a cp operation
		cp -rsfT "$foo" "${D}/pkg/main/${PKG}.dev.${PVRF}/include/$BASE"
	else
		ln -snfvT "$foo" "${D}/pkg/main/${PKG}.dev.${PVRF}/include/$BASE"
	fi
done

# c++ includes + libs
ln -snfv /pkg/main/sys-libs.libcxx.dev/include/c++ "${D}/pkg/main/${PKG}.dev.${PVRF}/include/"
ln -snfvT /pkg/main/sys-libs.libcxx.libs/lib$LIB_SUFFIX/libc++.so "${D}/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX/libc++.so"

# add link to ld.so.conf and ld.so.cache since binutils will be looking for it here
mkdir "${D}/pkg/main/${PKG}.dev.${PVRF}/etc"
ln -snf /pkg/main/azusa.symlinks.core/etc/ld.so.* "${D}/pkg/main/${PKG}.dev.${PVRF}/etc/"

# move etc/rpc
mv -v "${D}/etc/rpc" "${D}/pkg/main/${PKG}.dev.${PVRF}/etc/"

# add a link to /pkg in sysroot, because binutils will always prefix sysroot to paths found in ld.so.conf
ln -snfT /pkg "${D}/pkg/main/${PKG}.dev.${PVRF}/pkg"

# symlink share/zoneinfo to /pkg/main/sys-libs.timezone-data.core
ln -snfT /pkg/main/sys-libs.timezone-data.core "${D}/pkg/main/${PKG}.core.${PVRF}/share/zoneinfo"

archive
