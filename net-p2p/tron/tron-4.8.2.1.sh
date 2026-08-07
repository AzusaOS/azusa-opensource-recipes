#!/bin/sh
source "../../common/init.sh"

# java-tron (the TRON full node) releases are tagged GreatVoyage-v<version>
get https://github.com/tronprotocol/java-tron/archive/refs/tags/GreatVoyage-v${PV}.tar.gz ${P}.tar.gz
envcheck
# use envcheck (not acheck) so the gradle wrapper can fetch its distribution
# and the build dependencies from the network during the build

# java-tron requires JDK 8 on amd64 (it only allows JDK 17 on arm64)
setjava 8
export JAVA_HOME="$JAVAHOME"
export PATH="$JAVA_HOME/bin:$PATH"

cd "${S}"

# build the self-contained FullNode jar with the pinned gradle wrapper (7.6.4),
# skipping tests
./gradlew --no-daemon clean build -x test

DEST="${D}/pkg/main/${PKG}.core.${PVRF}"

# install the fat jar (framework/build/libs/FullNode.jar) and a launcher
JAR="$(find . -type f -name FullNode.jar -path '*build/libs/*' | head -n1)"
[ -n "$JAR" ] || die "FullNode.jar not found after build"
install -v -D -m 0644 "$JAR" "$DEST/share/java-tron/FullNode.jar"

mkdir -pv "$DEST/bin"
cat >"$DEST/bin/java-tron" <<EOF
#!/bin/sh
exec /pkg/main/dev-java.openjdk.core.8/bin/java -jar /pkg/main/${PKG}.core.${PVRF}/share/java-tron/FullNode.jar "\$@"
EOF
chmod -v +x "$DEST/bin/java-tron"

finalize
