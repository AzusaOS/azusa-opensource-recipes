#!/bin/sh
source "../../common/init.sh"

fetchgit https://github.com/intel/SGXDataCenterAttestationPrimitives.git "DCAP_${PV}"
cd "${S}/QuoteGeneration"
ae_file_name=prebuilt_dcap_${PV}.tar.gz
checksum_file=SHA256SUM_prebuilt_dcap_${PV}.cfg
server_url_path=https://download.01.org/intel-sgx/sgx-dcap/${PV}/linux/
get "$server_url_path/$ae_file_name"
get "$server_url_path/$checksum_file"
sha256sum -c "$checksum_file"
mv prebuilt ..
mkdir -p "${S}/QuoteVerification/sgxssl"
cd "${S}/QuoteVerification/sgxssl"
get "https://github.com/intel/intel-sgx-ssl/archive/3.0_Rev4.zip"
mv intel-sgx-ssl-3.0_Rev4/* .
cd openssl_source
download "https://www.openssl.org/source//old/3.0/openssl-3.0.14.tar.gz"
acheck

cd "${S}/QuoteGeneration"

. /pkg/main/dev-libs.sgx-sdk-bin.dev/environment
importpkg dev-libs/boost net-misc/curl

# inject LDFLAGS
sed -i -e "56i QGS_LFLAGS += $LDFLAGS" quote_wrapper/qgs/Makefile

# ugly hack to make the build work
mkdir -p "/usr/include/bits"
echo "#include <unistd.h>" >"/usr/include/bits/confname.h"
echo "#include \"/pkg/main/sys-libs.glibc.dev/include/bits/confname.h\"" >>"/usr/include/bits/confname.h"
# _SC_PAGESIZE

make dcap

# move stuff
mkdir -p "${D}/pkg/main/${PKG}.core.${PVRF}"

# tdx-qgs tee-appraisal-tool
for pkg in libsgx-ae-id-enclave libsgx-ae-qe3 libsgx-ae-qve libsgx-ae-tdqe libsgx-dcap-default-qpl libsgx-dcap-ql libsgx-dcap-quote-verify libsgx-pce-logic libsgx-qe3-logic libsgx-tdx-logic libtdx-attest; do
	./installer/linux/common/$pkg/createTarball.sh
	# for each package
	find installer/linux/common/$pkg/output -ls
	if [ -d installer/linux/common/$pkg/output/pkgroot ]; then
		for foo in ./installer/linux/common/$pkg/output/pkgroot/*; do
			rsync -av --progress "$foo"/ "${D}/pkg/main/${PKG}.core.${PVRF}/"
		done
	else
		if [ -d installer/linux/common/$pkg/output/lib ]; then
			rsync -av --progress installer/linux/common/$pkg/output/lib "${D}/pkg/main/${PKG}.core.${PVRF}/"
		fi
	fi
done

finalize
