#!/bin/sh
source "../../common/init.sh"

get https://github.com/emscripten-core/emscripten/archive/refs/tags/${PV}.tar.gz ${P}.tar.gz
acheck

mkdir -p "${D}/pkg/main"
mv -v "${S}" "${D}/pkg/main/${PKG}.core.${PVRF}"

cd "${D}/pkg/main/${PKG}.core.${PVRF}"

cat >emscripten.config <<EOF
import os

# this helps projects using emscripten find it
EMSCRIPTEN_ROOT = os.path.expanduser(os.getenv('EMSCRIPTEN') or '/pkg/main/${PKG}.core.${PVRF}') # directory
BINARYEN_ROOT = os.path.expanduser(os.getenv('BINARYEN_ROOT') or '/pkg/main/dev-util.binaryen.core/bin')
LLVM_ROOT = os.path.expanduser(os.getenv('LLVM') or '/pkg/main/sys-devel.llvm-full.core/bin') # directory

# If not specified, defaults to sys.executable.
#PYTHON = 'python'

# Add this if you have manually built the JS optimizer executable (in Emscripten/tools/optimizer) and want to run it from a custom location.
# Alternatively, you can set this as the environment variable EMSCRIPTEN_NATIVE_OPTIMIZER.
# EMSCRIPTEN_NATIVE_OPTIMIZER='/path/to/custom/optimizer(.exe)'

# See below for notes on which JS engine(s) you need
NODE_JS = os.path.expanduser(os.getenv('NODE') or '/pkg/main/net-libs.nodejs.core/bin/node') # executable
SPIDERMONKEY_ENGINE = [os.path.expanduser(os.getenv('SPIDERMONKEY') or 'js')] # executable
V8_ENGINE = os.path.expanduser(os.getenv('V8') or 'd8') # executable

JAVA = 'java' # executable

TEMP_DIR = '/tmp'

CRUNCH = os.path.expanduser(os.getenv('CRUNCH') or 'crunch') # executable

#CLOSURE_COMPILER = '..' # define this to not use the bundled version

########################################################################################################


# Pick the JS engine to use for running the compiler. This engine must exist, or
# nothing can be compiled.
#
# Recommendation: If you already have node installed, use that. Otherwise, build v8 or
#                 spidermonkey from source. Any of these three is fine, as long as it's
#                 a recent version (especially for v8 and spidermonkey).

COMPILER_ENGINE = NODE_JS
#COMPILER_ENGINE = V8_ENGINE
#COMPILER_ENGINE = SPIDERMONKEY_ENGINE


# All JS engines to use when running the automatic tests. Not all the engines in this list
# must exist (if they don't, they will be skipped in the test runner).
#
# Recommendation: If you already have node installed, use that. If you can, also build
#                 spidermonkey from source as well to get more test coverage (node can't
#                 run all the tests due to node issue 1669). v8 is currently not recommended
#                 here because of v8 issue 1822.

JS_ENGINES = [NODE_JS] # add this if you have spidermonkey installed too, SPIDERMONKEY_ENGINE]
EOF

# create wrappers that will run the wrappers to run the python stuff
mkdir bin
for foo in emcc emcmake; do
	echo "Creating bin/$foo ..."

	cat >bin/$foo <<EOF
#!/bin/sh
export EM_CONFIG=/pkg/main/${PKG}.core.${PVRF}/emscripten.config
export EMSDK_PYTHON=/pkg/main/dev-lang.python.core/bin/python
exec "/pkg/main/${PKG}.core.${PVRF}/$foo" "\$@"
EOF
	chmod +x bin/$foo
done

cd "${T}"

archive
