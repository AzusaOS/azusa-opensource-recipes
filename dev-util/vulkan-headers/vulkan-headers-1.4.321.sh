#!/bin/sh
source "../../common/init.sh"

MY_PN=Vulkan-Headers
get https://github.com/KhronosGroup/${MY_PN}/archive/vulkan-sdk-${PV}.tar.gz ${P}.tar.gz
acheck

cd "${T}"

docmake

finalize
