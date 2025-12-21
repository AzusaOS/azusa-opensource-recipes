#!/bin/sh

# setup env for java in /etc/java-config-2 based on /pkg/main/dev-java.openjdk.core
setjava() {
	JAVAHOME="/pkg/main/dev-java.openjdk.core"
	if [ "$1" != "" ]; then
		JAVAHOME="/pkg/main/dev-java.openjdk.core.$1"
	fi
	export JAVAHOME
	mkdir -p /etc/java-config-2
	ln -snfv "$JAVAHOME" "/etc/java-config-2/current-system-vm"
}
