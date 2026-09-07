#!/bin/sh
source "../../common/init.sh"

# upstream has no tagged releases, track master snapshots
CommitId=037cc6d74cbb4a89e443117459b577d56a582e54

get https://github.com/BlockstreamResearch/secp256k1-zkp/archive/${CommitId}.tar.gz "${P}.tar.gz"
acheck

cd "${S}"

aautoreconf

cd "${T}"

# the zkp modules are all marked experimental upstream; enable the full set
# so the library is usable by elements / rust-secp256k1-zkp / libwally style
# consumers
doconf \
	--enable-experimental \
	--enable-module-ecdh \
	--enable-module-recovery \
	--enable-module-extrakeys \
	--enable-module-schnorrsig \
	--enable-module-musig \
	--enable-module-schnorrsig-halfagg \
	--enable-module-ellswift \
	--enable-module-silentpayments \
	--enable-module-generator \
	--enable-module-rangeproof \
	--enable-module-surjectionproof \
	--enable-module-whitelist \
	--enable-module-ecdsa-s2c \
	--enable-module-bppp \
	--enable-module-ecdsa-adaptor \
	--disable-benchmark \
	--disable-tests \
	--disable-exhaustive-tests \
	--disable-ctime-tests \
	--disable-examples

make -j"$NPROC"
make install DESTDIR="${D}"

finalize
