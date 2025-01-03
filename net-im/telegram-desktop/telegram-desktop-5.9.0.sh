#!/bin/sh
source "../../common/init.sh"

fetchgit https://github.com/telegramdesktop/tdesktop.git "v${PV}"
acheck

# telegram doesn't build if not from its source dir
cd "${S}"

docmake || /bin/bash -i

finalize
