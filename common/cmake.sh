# Cmake utils

docmake() {
	echo "Running cmake..."
	if [ x"$CMAKE_ROOT" = x ]; then
		CMAKE_ROOT="${S}"
	fi

	# build custom rules (gentoo inspired)
	local build_rules="${CHPATH}/azusa_rules.cmake"

	cat >"$build_rules" <<EOF
set(CMAKE_ASM_COMPILE_OBJECT "<CMAKE_ASM_COMPILER> <DEFINES> <INCLUDES> ${CPPFLAGS} <FLAGS> -o <OBJECT> -c <SOURCE>" CACHE STRING "ASM compile command" FORCE)
set(CMAKE_ASM-ATT_COMPILE_OBJECT "<CMAKE_ASM-ATT_COMPILER> <DEFINES> <INCLUDES> ${CPPFLAGS} <FLAGS> -o <OBJECT> -c -x assembler <SOURCE>" CACHE STRING "ASM-ATT compile command" FORCE)
set(CMAKE_ASM-ATT_LINK_FLAGS "-nostdlib" CACHE STRING "ASM-ATT link flags" FORCE)
set(CMAKE_C_COMPILE_OBJECT "<CMAKE_C_COMPILER> <DEFINES> <INCLUDES> ${CPPFLAGS} <FLAGS> -o <OBJECT> -c <SOURCE>" CACHE STRING "C compile command" FORCE)
set(CMAKE_CXX_COMPILE_OBJECT "<CMAKE_CXX_COMPILER> <DEFINES> <INCLUDES> ${CPPFLAGS} <FLAGS> -o <OBJECT> -c <SOURCE>" CACHE STRING "C++ compile command" FORCE)
set(CMAKE_Fortran_COMPILE_OBJECT "<CMAKE_Fortran_COMPILER> <DEFINES> <INCLUDES> ${FCFLAGS} <FLAGS> -o <OBJECT> -c <SOURCE>" CACHE STRING "Fortran compile command" FORCE)
EOF

	local common_config="${CHPATH}/azusa_common_config.cmake"
	cat >"$common_config" <<EOF
set(LIB_SUFFIX "${LIB_SUFFIX}" CACHE STRING "library path suffix" FORCE)
set(CMAKE_INSTALL_BINDIR "/pkg/main/${PKG}.core.${PVRF}/bin" CACHE PATH "")
set(CMAKE_INSTALL_DATADIR "/pkg/main/${PKG}.core.${PVRF}/share" CACHE PATH "")
set(CMAKE_INSTALL_LIBDIR "/pkg/main/${PKG}.libs.${PVRF}/lib${LIB_SUFFIX}" CACHE PATH "Output directory for libraries")
set(CMAKE_INSTALL_DOCDIR "/pkg/main/${PKG}.doc.${PVRF}" CACHE PATH "")
set(CMAKE_INSTALL_INFODIR "/pkg/main/${PKG}.doc.${PVRF}/info" CACHE PATH "")
set(CMAKE_INSTALL_MANDIR "/pkg/main/${PKG}.doc.${PVRF}/man" CACHE PATH "")
set(CMAKE_USER_MAKE_RULES_OVERRIDE "${build_rules}" CACHE FILEPATH "Azusa override rules")
EOF

	# for kde's extra-cmake-modules
	export ECM_DIR=/pkg/main/kde-frameworks.extra-cmake-modules.core/share/ECM/cmake

	echo "CMAKE_SYSTEM_LIBRARY_PATH = $CMAKE_SYSTEM_LIBRARY_PATH"
	echo "CMAKE_SYSTEM_INCLUDE_PATH = $CMAKE_SYSTEM_INCLUDE_PATH"
	echo "CPPFLAGS = $CPPFLAGS"

	if [ x"$CMAKE_BUILD_ENGINE" = x ]; then
		CMAKE_BUILD_ENGINE="Ninja"
	fi

	set -- -S "$CMAKE_ROOT" -B "$PWD" \
		-C "$common_config" \
		-G "$CMAKE_BUILD_ENGINE" -Wno-dev \
		-DCMAKE_INSTALL_PREFIX="/pkg/main/${PKG}.core.${PVRF}" \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_SYSTEM_INCLUDE_PATH="${CMAKE_SYSTEM_INCLUDE_PATH}" \
		-DCMAKE_SYSTEM_LIBRARY_PATH="${CMAKE_SYSTEM_LIBRARY_PATH}" \
		-DCMAKE_C_FLAGS="${CPPFLAGS} -O2" \
		-DCMAKE_CXX_FLAGS="${CPPFLAGS} -O2" \
		"$@"

	echo -n "Running: cmake "
	printargs "$@"

	if [ "$CMAKE_DEBUG" != "" ]; then
		/bin/bash -i; exit 1
	fi
	cmake "$@" || return $?

	echo "Invoking compiler..."

	if [ x"$CMAKE_TARGET_ALL" = x ]; then
		CMAKE_TARGET_ALL="all"
	fi
	if [ x"$CMAKE_TARGET_ALL" = x"skip" ]; then
		# do not build (yet)
		return
	fi
	if [ x"$CMAKE_TARGET_INSTALL" = x ]; then
		CMAKE_TARGET_INSTALL="install"
	fi

	case $CMAKE_BUILD_ENGINE in
		Ninja)
			ninja -j"$NPROC" -v "$CMAKE_TARGET_ALL" || return $?
			for tgt in $CMAKE_EXTRA_TARGETS; do
				ninja -j"$NPROC" -v "$tgt" || return $?
			done
			if [ "$CMAKE_TARGET_INSTALL" != "skip" ]; then
				DESTDIR="${D}" ninja -j"$NPROC" -v "$CMAKE_TARGET_INSTALL" || return $?
			fi
			;;
		Unix\ Makefiles)
			make -j"$NPROC" "$CMAKE_TARGET_ALL" VERBOSE=1 || return $?
			for tgt in $CMAKE_EXTRA_TARGETS; do
				make -j"$NPROC" "$tgt" VERBOSE=1 || return $?
			done
			if [ "$CMAKE_TARGET_INSTALL" != "skip" ]; then
				make "$CMAKE_TARGET_INSTALL" VERBOSE=1 DESTDIR="${D}" || return $?
			fi
			;;
		*)
			echo "Invalid value for CMAKE_BUILD_ENGINE: $CMAKE_BUILD_ENGINE"
			exit 1
	esac
}

# @FUNCTION: cmake_comment_add_subdirectory
# @USAGE: <subdirectory>
# @DESCRIPTION:
# Comment out one or more add_subdirectory calls in CMakeLists.txt in the current directory
cmake_comment_add_subdirectory() {
	if [[ -z ${1} ]]; then
		die "${FUNCNAME[0]} must be passed at least one directory name to comment"
	fi

	[[ -e "CMakeLists.txt" ]] || return

	local d
	for d in $@; do
		d=${d//\//\\/}
		sed -e "/add_subdirectory[[:space:]]*([[:space:]]*${d}[[:space:]]*)/I s/^/#DONOTCOMPILE /" \
			-i CMakeLists.txt || die "failed to comment add_subdirectory(${d})"
	done
}

