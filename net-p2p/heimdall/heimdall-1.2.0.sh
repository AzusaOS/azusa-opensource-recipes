#!/bin/sh
source "../../common/init.sh"

LAUNCH_COMMIT=fe86ba6c
fetchgit https://github.com/maticnetwork/heimdall.git v${PV}
fetchgit https://github.com/maticnetwork/launch.git $LAUNCH_COMMIT

envcheck
# do not use acheck so we keep networking

export PATH="/pkg/main/dev-lang.go.dev/bin:$PATH"
export GOBIN="${D}/pkg/main/${PKG}.core.${PVRF}/bin"
mkdir -pv "$GOBIN"

cd "${S}"
make install

cp README.md LICENSE "${D}/pkg/main/${PKG}.core.${PVRF}/"
cp -rv packaging/templates/config "${D}/pkg/main/${PKG}.core.${PVRF}/"
cp -v "$WORKDIR/launch-$LAUNCH_COMMIT/mainnet-v1/sentry/sentry/heimdall/config/genesis.json" "${D}/pkg/main/${PKG}.core.${PVRF}/config/mainnet"

mkdir -p "${D}/pkg/main/${PKG}.core.${PVRF}/launch-config"
cp -rv "$WORKDIR/launch-$LAUNCH_COMMIT"/{mainnet-v1,testnet-v4} "${D}/pkg/main/${PKG}.core.${PVRF}/launch-config"

if [ ! -f "$GOBIN/heimdalld" ]; then
	echo "Build failed"
	exit
fi

finalize
