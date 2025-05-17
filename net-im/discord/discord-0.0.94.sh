#!/bin/sh
source "../../common/init.sh"

# check latest version:
# curl -v 'https://discord.com/api/download?platform=linux&format=tar.gz' 2>&1 | grep -i 'location:'

get https://stable.dl2.discordapp.net/apps/linux/${PV}/discord-${PV}.tar.gz
#acheck

mkdir -pv "${D}/pkg/main/${PKG}.core.${PVRF}/bin"
mv -v Discord "${D}/pkg/main/${PKG}.core.${PVRF}"

# only put Discord in bin

cd "${D}/pkg/main/${PKG}.core.${PVRF}"
cat >bin/Discord <<EOF
#!/bin/sh
exec /pkg/main/${PKG}.core.${PVRF}/Discord/Discord "\$@"
EOF

chmod +x bin/Discord

fixelf
archive
