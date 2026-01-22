#!/bin/sh
source "../../common/init.sh"

fetchgit https://github.com/anza-xyz/agave.git v"${PV}"
envcheck

importpkg libudev

# we keep networking alive for cargo
cd "${S}"

CARGO_VERSION="$(cat rust-toolchain.toml | grep ^channel | sed -e 's/"$//;s/.*"//')"
export PATH="/pkg/main/dev-lang.rust.core.$CARGO_VERSION/bin:$PATH"

echo "#!/bin/sh" >cargo
echo "exec /pkg/main/dev-lang.rust.core.$CARGO_VERSION/bin/cargo \"\$@\"" >>cargo

# fix for rust librocksdb-sys
export CXXFLAGS="-include cstdint"

./scripts/cargo-install-all.sh "${D}/pkg/main/${PKG}.core.${PVRF}"
 #cargo build --release --workspace

finalize
