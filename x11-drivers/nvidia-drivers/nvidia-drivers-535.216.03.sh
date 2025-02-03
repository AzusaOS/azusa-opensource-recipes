#!/bin/sh
source "../../common/init.sh"

NV_URI="https://download.nvidia.com/XFree86/"
get ${NV_URI}Linux-x86_64/${PV}/NVIDIA-Linux-x86_64-${PV}.run
acheck

chmod +x NVIDIA-Linux-x86_64-${PV}.run
./NVIDIA-Linux-x86_64-${PV}.run --extract-only
cd NVIDIA-Linux-x86_64-${PV}

mkdir -p "${D}/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX"
mv lib*.so* "${D}/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX"

if [ -d 32 ]; then
	mkdir -p "${D}/pkg/main/${PKG}.libs.${PVR}.${OS}.386/lib"
	mv 32/lib*.so* "${D}/pkg/main/${PKG}.libs.${PVR}.${OS}.386/lib"
	echo "Running ldconfig..."
	echo "/pkg/main/${PKG}.libs.${PVR}.${OS}.386/lib" >>"${D}/pkg/main/${PKG}.libs.${PVR}.${OS}.386/.ld.so.conf"
	/pkg/main/sys-libs.glibc.core/sbin/ldconfig --format=new -v -r "${D}" -C "/pkg/main/${PKG}.libs.${PVR}.${OS}.386/.ld.so.cache" -f "/pkg/main/${PKG}.libs.${PVR}.${OS}.386/.ld.so.conf" 
fi

mkdir -p "${D}/pkg/main/${PKG}.data.${PVR}.any.any"
mv firmware "${D}/pkg/main/${PKG}.data.${PVR}.any.any"
mkdir -p "${D}/pkg/main/${PKG}.doc.${PVRF}"
mv LICENSE html supported-gpus "${D}/pkg/main/${PKG}.doc.${PVRF}"

mkdir -p "${D}/pkg/main/${PKG}.core.${PVRF}/bin"
mkdir -p "${D}/pkg/main/${PKG}.core.${PVRF}/libexec"
for foo in nvidia-cuda-mps-control nvidia-cuda-mps-server nvidia-debugdump nvidia-ngx-updater nvidia-smi nvidia-bug-report.sh nvidia-modprobe nvidia-settings nvidia-xconfig nvidia-persistenced; do
	if [ ! -f "$foo" ]; then
		continue
	fi

	case "$foo" in
		*.sh)
			:
			;;
		*)
			patchelf --add-rpath "/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX" "$foo"
	esac

	mv -v "$foo" "${D}/pkg/main/${PKG}.core.${PVRF}/libexec"

	if [ -f "${foo}.1.gz" ]; then
		mkdir -p "${D}/pkg/main/${PKG}.doc.${PVRF}/man/man1"
		mv "${foo}.1.gz" "${D}/pkg/main/${PKG}.doc.${PVRF}/man/man1"
	fi
	cat >"${D}/pkg/main/${PKG}.core.${PVRF}/bin/$foo" <<EOF
#!/bin/sh
if [ -f /sys/module/nvidia/version ]; then
	NVIDIA_VERS="\$(cat /sys/module/nvidia/version)"
	if [ -d "/pkg/main/${PKG}.core.\${NVIDIA_VERS}" ]; then
		exec "/pkg/main/${PKG}.core.\${NVIDIA_VERS}/libexec/$foo" "\$@"
	fi
	echo >&2 "error: nvidia driver version \${NVIDIA_VERS} not supported, file a bug at https://github.com/AzusaOS/azusa-opensource-recipes/issues"
	exit 1
fi
# fallback
exec "/pkg/main/${PKG}.core.${PVRF}/libexec/$foo" "\$@"
EOF
	chmod +x "${D}/pkg/main/${PKG}.core.${PVRF}/bin/$foo"
done

finalize
