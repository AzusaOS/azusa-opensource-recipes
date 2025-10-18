#!/bin/sh
source "../../common/init.sh"

MY_DATE="${PV/*.}"
MY_PN="${PN/smc-/}"
MY_PV="${PV%.*}"

get "https://www.supermicro.com/Bios/sw_download/698/${MY_PN}_${MY_PV}_Linux_x86_64_${MY_DATE}.tar.gz"
#acheck

mkdir -p "${D}/pkg/main/${PKG}.core.${PVRF}/bin"

mv "${S}" "${D}/pkg/main/${PKG}.data.${PVRF}"

cat >"${D}/pkg/main/${PKG}.core.${PVRF}/bin/sum" <<EOF
#!/bin/bash
exec "/pkg/main/${PKG}.data.${PVRF}/sum" "$@"
EOF
chmod +x "${D}/pkg/main/${PKG}.core.${PVRF}/bin/sum"

finalize
