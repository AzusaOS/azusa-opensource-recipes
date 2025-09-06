#!/bin/sh
source "../../common/init.sh"

BINPKG="${P/-bin/}-1"
ARCHES="amd64 arm64 riscv"

for arch in $ARCHES; do
	get "https://dev.gentoo.org/~chewi/distfiles/${BINPKG}-${arch}.xpak"
done

acheck

cd "${T}"

mkdir -p "${D}/pkg/main/${PKG}.data.${PVRF}/share/edk2"

for arch in $ARCHES; do
	mkdir -p "${arch}"
	xz -c -d --single-stream "$WORKDIR/${BINPKG}-${arch}.xpak" | tar -C "${arch}" -xf -

	mv -v ${arch}/usr/share/edk2/* "${D}/pkg/main/${PKG}.data.${PVRF}/share/edk2"
	mkdir -p "${D}/pkg/main/${PKG}.data.${PVRF}/share/qemu-${arch}"
	mv -v ${arch}/usr/share/qemu/* "${D}/pkg/main/${PKG}.data.${PVRF}/share/qemu-${arch}"
	# fix paths in .json files
	sed -i -e 's#"/usr/share/edk2#"/pkg/main/'"${PKG}.data.${PVRF}"'/share/edk2#' "${D}/pkg/main/${PKG}.data.${PVRF}/share/qemu-${arch}"/firmware/*.json
done

finalize
