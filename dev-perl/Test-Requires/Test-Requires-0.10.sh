#!/bin/sh
source "../../common/init.sh"
inherit perl

get https://cpan.metacpan.org/authors/id/T/TO/TOKUHIROM/${P}.tar.gz
acheck

cd "${P}"

perlsetup
finalize
