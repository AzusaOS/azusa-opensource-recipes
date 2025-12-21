#!/bin/sh
source "../../common/init.sh"

MY_PN=${PN}3
MECK_PV=0.8.13 # see rebar.config

get https://github.com/erlang/${MY_PN}/archive/refs/tags/${PV}.tar.gz ${P}.tar.gz
acheck

cd "${S}"

./bootstrap

dobin $MY_PN
dodoc rebar.config.sample
doman manpages/${MY_PN}.1

finalize
