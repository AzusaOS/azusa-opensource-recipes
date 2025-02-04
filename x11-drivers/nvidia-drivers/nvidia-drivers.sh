# nvidia drivers

nvidia_download_redist() {
	case "$ARCH" in
		amd64)
			get https://developer.download.nvidia.com/compute/nvidia-driver/redist/nvidia_driver/linux-x86_64/nvidia_driver-linux-x86_64-${PV}-archive.tar.xz
			;;
		*)
			echo "Unsupported arch: $ARCH"
			exit 1
	esac
}

nvidia_process_redist() {
	# download version as redistribuable
	nvidia_download_redist

	nvidia_process
	finalize
}

nvidia_download_xfree86() {
	NV_URI="https://download.nvidia.com/XFree86/"
	get ${NV_URI}Linux-x86_64/${PV}/NVIDIA-Linux-x86_64-${PV}.run

	# TODO might have a better way to extract this?
	chmod +x NVIDIA-Linux-x86_64-${PV}.run
	./NVIDIA-Linux-x86_64-${PV}.run --extract-only
	S="$PWD/NVIDIA-Linux-x86_64-${PV}"
}

nvidia_organize_xfree86() {
	# attempt to organize flat stuff from xfree86 distrib to something similar to redist
	cd "${S}"
	[ -d 32 ] && mv 32 lib32
	mkdir lib
	mv lib*.so* lib
	nvidia_mvto lib nvidia_drv.so
	mkdir -p man/man1
	mv *.1.gz man/man1
	mv .manifest MANIFEST
	nvidia_mvto bin nvidia-installer  nvidia-modprobe  nvidia-pcc  nvidia-persistenced  nvidia-settings  nvidia-xconfig
	nvidia_mvto sbin nvidia-bug-report.sh  nvidia-cuda-mps-control  nvidia-cuda-mps-server  nvidia-debugdump  nvidia-ngx-updater  nvidia-powerd  nvidia-smi
	nvidia_mvto wine _nvngx.dll  nvngx.dll  nvngx_dlssg.dll
	nvidia_mvto etc 10_nvidia.json 10_nvidia_wayland.json 15_nvidia_gbm.json 20_nvidia_xcb.json 20_nvidia_xlib.json nvidia-application-profiles-* nvidia-dbus.conf nvidia-drm-outputclass.conf nvidia.icd nvidia_icd.json nvidia_icd_vksc.json nvidia_layers.json
	nvidia_mvto share makeself-help-script.sh  makeself.sh  mkprecompiled  nvidia-settings.desktop  nvidia-settings.png  nvoptix.bin  sandboxutils-filelist.json
}

nvidia_process_xfree86() {
	nvidia_download_xfree86
	nvidia_organize_xfree86

	nvidia_process
	finalize
}

nvidia_mvto() {
	local tgt="$1"
	shift

	while [ "$1" != "" ]; do
		[ -e "$1" ] && mkdir -p "$tgt" && mv -v $1 "$tgt"
		shift
	done
}

nvidia_process() {
	cd "$S"

	mkdir -p "${D}/pkg/main/${PKG}.libs.${PVRF}"
	mv lib "${D}/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX"
	for foo in "${D}/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX"/*.so.*; do
		ln -snf "$(basename "$foo")" "${foo%%.so.*}.so"
	done

	# lib32
	if [ -d lib32 ]; then
		mkdir -p "${D}/pkg/main/${PKG}.libs.${PVR}.${OS}.386"
		mv lib32 "${D}/pkg/main/${PKG}.libs.${PVR}.${OS}.386/lib"
		echo "Running ldconfig..."
		echo "/pkg/main/${PKG}.libs.${PVR}.${OS}.386/lib" >>"${D}/pkg/main/${PKG}.libs.${PVR}.${OS}.386/.ld.so.conf"
		/pkg/main/sys-libs.glibc.core/sbin/ldconfig --format=new -v -r "${D}" -C "/pkg/main/${PKG}.libs.${PVR}.${OS}.386/.ld.so.cache" -f "/pkg/main/${PKG}.libs.${PVR}.${OS}.386/.ld.so.conf" 
		for foo in "${D}/pkg/main/${PKG}.libs.${PVR}.${OS}.386/lib"/*.so.*; do
			ln -snf "$(basename "$foo")" "${foo%%.so.*}.so"
		done
	fi

	# sources (kernel, etc)
	nvidia_mvto "${D}/pkg/main/${PKG}.src.${PVR}.any.any" src kernel kernel-open
	# firmware
	nvidia_mvto "${D}/pkg/main/${PKG}.data.${PVR}.any.any" firmware
	# doc
	nvidia_mvto "${D}/pkg/main/${PKG}.doc.${PVRF}" README README.txt MANIFEST LICENSE CHANGELOG NVIDIA_Changelog docs man supported-gpus html
	# core
	nvidia_mvto "${D}/pkg/main/${PKG}.core.${PVRF}" etc share systemd tests wine
	# binaries
	mkdir -p "${D}/pkg/main/${PKG}.core.${PVRF}/libexec"
	for bindir in bin sbin; do
		mkdir -p "${D}/pkg/main/${PKG}.core.${PVRF}/$bindir"
		for foo in $bindir/*; do
			case "$foo" in
				*.sh)
					:
					;;
				*)
					patchelf --add-rpath "/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX" "$foo"
			esac
			bfoo="$(basename "$foo")"

			mv -v "$foo" "${D}/pkg/main/${PKG}.core.${PVRF}/libexec"

			cat >"${D}/pkg/main/${PKG}.core.${PVRF}/$foo" <<EOF
#!/bin/sh
if [ -f /sys/module/nvidia/version ]; then
	NVIDIA_VERS="\$(cat /sys/module/nvidia/version)"
	if [ -d "/pkg/main/${PKG}.core.\${NVIDIA_VERS}" ]; then
		exec "/pkg/main/${PKG}.core.\${NVIDIA_VERS}/libexec/$bfoo" "\$@"
	fi
	echo >&2 "error: nvidia driver version \${NVIDIA_VERS} not supported, file a bug at https://github.com/AzusaOS/azusa-opensource-recipes/issues"
	exit 1
fi
# fallback
exec "/pkg/main/${PKG}.core.${PVRF}/libexec/$bfoo" "\$@"
EOF
			chmod +x "${D}/pkg/main/${PKG}.core.${PVRF}/$foo"
		done
	done
}
