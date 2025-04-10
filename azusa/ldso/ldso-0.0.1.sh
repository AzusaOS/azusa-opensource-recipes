#!/bin/bash
source "../../common/init.sh"

TZ=`date +%Y%m%d`
MY_PVR="${PVR}.${TZ}.${OS}.${ARCH}"

mkdir -p "${D}/pkg/main/${PKG}.data.${MY_PVR}"
cd "${D}/pkg/main/${PKG}.data.${MY_PVR}"

# possible libs directories
LIBS="lib lib32 lib64"

mkdir etc
ln -s /pkg/main/sys-libs.glibc.dev/etc/rpc etc/rpc

scanlibs() {
	for pn in $(curl -s "http://localhost:100/apkgdb/main?action=list&sub=$1" | grep -v busybox | grep libs); do
		p=/pkg/main/${pn}
		t=`echo "$pn" | cut -d. -f3`
		if [ $t != "libs" ]; then
			continue
		fi
		echo -ne "\rScanning: $pn\033[K"
		if [ ! -f "${p}/.ld.so.cache" ]; then
			# only issue warning if there is no such file in latest version too
			pt="/pkg/main/$(echo "$pn" | cut -d. -f1-3).$1"
			if [ ! -f "${pt}/.ld.so.cache" ]; then
				echo -e "\rMissing ld config file: $pn"
			fi
		fi
		for foo in $LIBS; do
			if [ -d "${p}/$foo" -a ! -L "${p}/$foo" ]; then
				echo "${p}/$foo" >>etc/ld.so.conf.tmp
				if [ -d "${p}/$foo/$2" ]; then
					# some libs use this kind of paths for special libs
					echo "${p}/$foo/$2" >>etc/ld.so.conf.tmp
				fi
			fi
		done
	done
}

case $ARCH in
	amd64)
		# amd64 → also scan 32bits libs (scan first so they are lower priority)
		scanlibs "${OS}.386" "i686-pc-linux-gnu"
		;;
esac

scanlibs "${OS}.${ARCH}" "$CHOST"

# reverse order in ld.so.conf so newer versions are on top and taken in priority
tac etc/ld.so.conf.tmp >etc/ld.so.conf
rm etc/ld.so.conf.tmp

echo
echo "Generating ld.so.cache..."
if [ -f /pkg/main/sys-libs.glibc.core/sbin/ldconfig ]; then
	/pkg/main/sys-libs.glibc.core/sbin/ldconfig -X -C etc/ld.so.cache -f etc/ld.so.conf
else
	# can't be helped...?
	ldconfig -X -C etc/ld.so.cache -f etc/ld.so.conf
fi

archive
