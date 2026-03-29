#!/bin/sh
source "../../common/init.sh"

get https://github.com/radareorg/radare2/archive/${PV}.tar.gz "${P}.tar.gz"
cd "${S}/subprojects"
for foo in capstone-v5 qjs sdb otezip; do
	url="$(cat "$foo.wrap" | grep '^url =' | sed -e 's/.*= *//')"
	rev="$(cat "$foo.wrap" | grep '^revision =' | sed -e 's/.*= *//')"
	get "$(echo "$url" | sed -e 's/\.git$//')/archive/${rev}.tar.gz" "${P}-${foo}.tar.gz"
	mv -v "$(basename "$url" .git)-$rev" $foo
done

acheck

cd "${S}"

importpkg zlib dev-libs/xxhash dev-libs/capstone

#domeson -Duse_sys_capstone=true -Duse_sys_lz4=true -Duse_sys_magic=true -Duse_sys_xxhash=true -Duse_ssl=true -Duse_sys_zip=true
doconf --with-syscapstone --with-syslz4 --with-sysmagic --with-sysxxhash --with-syszip --with-ssl

make -j"$NPROC"
make install DESTDIR="${D}"

finalize
