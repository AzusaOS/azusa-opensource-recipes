#!/bin/sh
source "../../common/init.sh"

GIT_COMMIT="11427f3"
fetchgit https://github.com/ianlancetaylor/libbacktrace.git "$GIT_COMMIT"
acheck

cd "${T}"

doconf

make
make install DESTDIR="${D}"

finalize
