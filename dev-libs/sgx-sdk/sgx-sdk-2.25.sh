#!/bin/sh
source "../../common/init.sh"

fetchgit https://github.com/intel/linux-sgx.git "sgx_${PV}"

cd "${S}"
apatch "$FILESDIR/sgx-sdk-2.25-bug-1066-fixes.patch"

optlib_name=optimized_libs_${PV}.tar.gz
ae_file_name=prebuilt_ae_${PV}.tar.gz
binutils_file_name=as.ld.objdump.r4.tar.gz
checksum_file=SHA256SUM_prebuilt_${PV}.cfg
server_url_path=https://download.01.org/intel-sgx/sgx-linux/${PV}
get "$server_url_path/$optlib_name"
get "$server_url_path/$ae_file_name"
get "$server_url_path/$binutils_file_name"
get "$server_url_path/$checksum_file"
sha256sum -c "$checksum_file"
# download stuff
#cd "${S}/external/sgxssl"
#get "https://github.com/intel/intel-sgx-ssl/archive/3.0_Rev4.zip"
#cd "${S}/external/sgxssl/openssl_source"
#get "https://github.com/openssl/openssl/releases/download/openssl-3.0.14/openssl-3.0.14.tar.gz"

cd "${S}"
chown root.root -R . || true
make preparation
acheck

# see: https://github.com/intel/linux-sgx/issues/1066

cd "${S}"
# make preparation
/bin/bash -i
exit 1

finalize
