#!/bin/sh
source "../../common/init.sh"

DRIVER_PV="610.43.02"
cuda_supported_gcc="8.5 9.5 10 11 12 13 14 15"

get "https://developer.download.nvidia.com/compute/cuda/${PV}/local_installers/cuda_${PV}_${DRIVER_PV}_linux.run"
acheck

# extract this file (makeself 2.1*)
SRCFILE="cuda_${PV}_${DRIVER_PV}_linux.run"
skip_lines="$(grep -a offset=.*head.*wc "$SRCFILE" | awk '{ print $3 }' | head -n1)"
skip_bytes="$(head -n "$skip_lines" "$SRCFILE" | wc -c)"

# use dd the way gentoo does (I don't like this thing with ibs, but oh well, at least it works)
dd ibs="$skip_bytes" skip=1 if="$SRCFILE" of="${SRCFILE}.arch"

# let tar find out the right format
tar --no-same-owner -xf "${SRCFILE}.arch"

# CUDA 13 renamed cuda_cccl -> cccl, dropped cuda_demo_suite, and split the
# nvcc runtime-compilation headers (crt/) into cuda_crt and libculibos into
# cuda_culibos; libnvfatbin/libnvptxcompiler are the newer runtime libs.
builddirs=(
	builds/cccl
	builds/cuda_{crt,cudart,culibos,cuobjdump,cuxxfilt,nvcc,nvdisasm,nvml_dev,nvprune,nvrtc,nvtx,opencl}
	builds/lib{cublas,cufft,cufile,curand,cusolver,cusparse,npp,nvfatbin,nvjitlink,nvjpeg,nvptxcompiler}
	builds/nvidia_fs
)

mkdir -p "${D}/pkg/main/${PKG}.core.${PVRF}/bin"

for d in "${builddirs[@]}"; do
	echo "Installing ${d}"
	[[ -d ${d} ]] || die "Directory does not exist: ${d}"

	for x in bin targets share extras; do
		if [ -d "${d}/${x}" ]; then
			rsync -av "${d}/${x}" "${D}/pkg/main/${PKG}.core.${PVRF}/"
		fi
	done
done
cp builds/EULA.txt "${D}/pkg/main/${PKG}.core.${PVRF}/"

echo "Installing nvvm"
# CUDA 13 moved nvvm out of cuda_nvcc into its own libnvvm component
chmod +x builds/libnvvm/nvvm/bin/cicc
rsync -av builds/libnvvm/nvvm "${D}/pkg/main/${PKG}.core.${PVRF}/"

echo "Installing nvml"
rsync -av builds/cuda_nvml_dev/nvml "${D}/pkg/main/${PKG}.core.${PVRF}/"

# todo nsight

# move a bit stuff around
mkdir -p "${D}/pkg/main/${PKG}.libs.${PVRF}"
mkdir -p "${D}/pkg/main/${PKG}.dev.${PVRF}/lib$LIB_SUFFIX"

# move include
mv -v "${D}/pkg/main/${PKG}.core.${PVRF}/targets/x86_64-linux/include" "${D}/pkg/main/${PKG}.dev.${PVRF}/include"
ln -snf "/pkg/main/${PKG}.dev.${PVRF}/include" "${D}/pkg/main/${PKG}.core.${PVRF}/targets/x86_64-linux/include"

# move libs
mv -v "${D}/pkg/main/${PKG}.core.${PVRF}/targets/x86_64-linux/lib" "${D}/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX"
ln -snf "/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX" "${D}/pkg/main/${PKG}.core.${PVRF}/targets/x86_64-linux/lib"

ln -snf "/pkg/main/${PKG}.dev.${PVRF}/include" "${D}/pkg/main/${PKG}.core.${PVRF}/include"
ln -snf "/pkg/main/${PKG}.libs.${PVRF}/lib$LIB_SUFFIX" "${D}/pkg/main/${PKG}.core.${PVRF}/lib$LIB_SUFFIX"

#cuda-config
sed -e "s:CUDA_SUPPORTED_GCC:${cuda_supported_gcc}:g" \
	"${FILESDIR}"/cuda-config.in > "${D}/pkg/main/${PKG}.core.${PVRF}/bin/cuda-config"
chmod -v +x "${D}/pkg/main/${PKG}.core.${PVRF}/bin/cuda-config"

fixelf
archive
