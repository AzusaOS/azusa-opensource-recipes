#!/bin/sh
source ../../common/init.sh
inherit python

get https://github.com/gradio-app/gradio/archive/refs/tags/gradio@${PV}.tar.gz "${P}.tar.gz"
acheck

cd "${S}"

pythonsetup
archive
