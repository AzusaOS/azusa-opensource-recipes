#!/bin/sh
source "../../common/init.sh"
inherit perl

get https://www.cpan.org/authors/id/K/KA/KASEI/${P}.tar.gz
acheck

cd "${P}"

perlsetup
finalize
