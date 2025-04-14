#!/bin/sh
source "../../common/init.sh"

get https://download.01.org/intel-sgx/latest/linux-latest/distro/ubuntu24.04-server/sgx_linux_x64_sdk_${PV}.bin
acheck

# will create sgxsdk
chmod +x sgx_linux_x64_sdk_${PV}.bin
./sgx_linux_x64_sdk_${PV}.bin -prefix="/pkg/main/"

# move it out
mkdir -p "${D}/pkg/main"
mv "/pkg/main/sgxsdk" "${D}/pkg/main/${PKG}.dev.${PVRF}"

# update config
cd "${D}/pkg/main/${PKG}.dev.${PVRF}"
rm uninstall.sh
sed -i -e "s#/pkg/main/sgxsdk#/pkg/main/${PKG}.dev.${PVRF}#" bin/sgx-gdb environment pkgconfig/*.pc

# fix lib64/libsgx_urts.so.2
ln -snfv "libsgx_urts.so" "lib64/libsgx_urts.so.2"
# move libs
mkdir -p "${D}/pkg/main/${PKG}.libs.${PVRF}"
mv lib64 "${D}/pkg/main/${PKG}.libs.${PVRF}"
#ln -snfv "/pkg/main/${PKG}.libs.${PVRF}" lib64

# fix symlinks
for lnk in $(find . -type l); do
	tgt="$(readlink "$lnk" | sed "s#/pkg/main/sgxsdk#/pkg/main/${PKG}.dev.${PVRF}#")"
	ln -snfv "$tgt" "$lnk"
done

finalize
