ARCH=`uname -m`
BITS=`getconf LONG_BIT`
OS=`uname -s | tr A-Z a-z`
MULTILIB=no

case $ARCH in
	i?86)
		ARCH=386
		LIB_SUFFIX=
		CHOST="i686-pc-linux-gnu"
		BITS=32
		;;
	x86_64)
		if [ $BITS -eq 32 ]; then
			# let's force uname -m to be 32bits
			exec setarch i686 /bin/bash "$0" "$@"
			exit 1
		else
			ARCH=amd64
			MULTILIB=yes
			LIB_SUFFIX=64
			CHOST="x86_64-pc-linux-gnu"
		fi
		;;
	aarch64)
		ARCH=arm64
		LIB_SUFFIX=
		CHOST="aarch64-unknown-linux-gnu"
		;;
	ppc64le)
		ARCH=ppc64le
		LIB_SUFFIX=
		CHOST="ppc64le-unknown-linux-gnu"
		;;
	*)
		echo "Unsupported arch: $ARCH"
		exit 1
esac

# armv7-unknown-linux-gnueabi
