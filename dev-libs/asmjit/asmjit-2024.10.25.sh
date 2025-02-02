#!/bin/sh
source "../../common/init.sh"

CommitId=f1096428b87e9d16305de16e91f2a7f52aef5a88

get https://github.com/asmjit/${PN}/archive/${CommitId}.tar.gz "${P}.tar.gz"
acheck

cd "${T}"

docmake

finalize
