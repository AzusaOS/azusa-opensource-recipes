#!/bin/sh
source "../../common/init.sh"
inherit perl

get https://www.cpan.org/authors/id/D/DC/DCANTRELL/${P}.tar.gz
acheck

cd "${P}"

perlsetup
finalize
