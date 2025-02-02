#!/bin/sh
source ../../common/init.sh
inherit python

PYTHON_RESTRICT="$PYTHON_LATEST"

get https://github.com/pytorch/pytorch/releases/download/v${PV}/pytorch-v${PV}.tar.gz ${P}.tar.gz
acheck

inherit cuda
initcuda 12.4

importpkg sci-libs/caffe2

cd "${S}"

PATCHES=(
	"${FILESDIR}"/pytorch-2.5.1-dontbuildagain.patch
	"${FILESDIR}"/${P}-setup.patch
        "${FILESDIR}"/pytorch-1.9.0-Change-library-directory-according-to-CMake-build.patch
        #"${FILESDIR}"/pytorch-2.4.0-global-dlopen.patch
        #"${FILESDIR}"/pytorch-1.7.1-torch_shm_manager.patch
        #"${FILESDIR}"/${PN}-1.13.0-setup.patch
)

apatch "${PATCHES[@]}"

sed -i -e "/BUILD_DIR/s|build|/pkg/main/sci-libs.caffe2.dev.${PV}/torch_build/|" tools/setup_helpers/env.py

# apply torch_shm_manager here so we can use the right version in the path
# pytorch-1.7.1-torch_shm_manager.patch
echo "Applying torch_shm_manager path:"
sed -i -e "/^_C._initExtension/s|_manager_path()|b\"/pkg/main/sci-libs.caffe2.core.${PV}/bin/torch_shm_manager\"|" torch/__init__.py
cat torch/__init__.py | grep _initExtension

# apply pytorch-2.4.0-global-dlopen.patch with hardcoded path
# global_deps_lib_path = os.path.join(os.path.dirname(here), "lib", lib_name)
sed -i -e "/here = os.path.abspath(__file__)/d;/global_deps_lib_path/s#os.path.dirname(here)#\"/pkg/main/sci-libs.caffe2.libs.${PV}\"#" torch/__init__.py

# Get object file from caffe2
cp -v /pkg/main/sci-libs.caffe2.dev.${PV}/torch_build/functorch.so functorch/functorch.so

export PYTORCH_BUILD_VERSION="${PV}"
export PYTORCH_BUILD_NUMBER=0
export USE_SYSTEM_LIBS=ON
export CMAKE_BUILD_DIR="${T}"

pythonsetup

# copy version.py
cp -v "/pkg/main/sci-libs.caffe2.dev.${PV}/torch_build/version.py" "${D}/pkg/main/${PKG}.mod.${PVR}.py${PYTHON_RESTRICT}.${OS}.${ARCH}/lib/python${PYTHON_RESTRICT%.*}/site-packages/torch/version.py"

# create symlink to caffe2
# -I/pkg/main/sci-libs.pytorch.mod.2.2.1.py3.12.2.linux.amd64/lib/python3.12/site-packages/torch/include/torch/csrc/api/include
ln -snfv $(realpath /pkg/main/sci-libs.caffe2.dev.${PV}/include) $(echo ${D}/pkg/main/${PKG}.mod.*/lib/python*/site-packages/torch)/include

# inject rpath
find ${D}/pkg/main -name '*.so' | xargs patchelf --add-rpath /pkg/main/sci-libs.caffe2.libs.${PV}/lib

archive
