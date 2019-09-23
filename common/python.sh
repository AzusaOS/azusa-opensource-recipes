#!/bin/sh

# currently active python versions (for modules, etc)
PYTHON_VERSIONS="2.7.16 3.7.3"

PYTHON_MODS="dev-python/setuptools dev-python/pip dev-util/gyp"

# (from gentoo, to clean/remove/reuse?)
# Stub out ez_setup.py and distribute_setup.py to prevent packages
# from trying to download a local copy of setuptools.
disable_ez_setup() {
    local stub="def use_setuptools(*args, **kwargs): pass"
    if [[ -f ez_setup.py ]]; then
        echo "${stub}" > ez_setup.py || die
    fi
    if [[ -f distribute_setup.py ]]; then
        echo "${stub}" > distribute_setup.py || die
    fi
}

pythonsetup() {
	if [ ! -d /.pkg-main-rw ]; then
		echo "This needs to be built in Azusa Build env"
		exit
	fi

	mkdir -p "${D}/pkg/main"

	# perform install for all relevant versions of python
	for PYTHON_VERSION in $PYTHON_VERSIONS; do
		"/pkg/main/dev-lang.python.core.${PYTHON_VERSION}/bin/python${PYTHON_VERSION:0:1}" setup.py install

		# fetch the installed module from /.pkg-main-rw/
		mv "/.pkg-main-rw/dev-lang.python-modules.${PYTHON_VERSION}".* "${D}/pkg/main/${PKG}.mod.${PVR}.py${PYTHON_VERSION}"
	done
}
