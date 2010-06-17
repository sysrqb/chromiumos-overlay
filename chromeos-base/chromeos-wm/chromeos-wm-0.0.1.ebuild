# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Chrome OS window manager."
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE="opengles"

RDEPEND="chromeos-base/crash-dumper
	dev-cpp/gflags
	dev-cpp/glog
	dev-libs/libpcre
	dev-libs/protobuf
	media-libs/libpng
	x11-libs/cairo
	x11-libs/libxcb
	x11-libs/libX11
	x11-libs/libXdamage
	x11-libs/libXext
	!opengles? ( virtual/opengl )
	opengles? ( virtual/opengles )"
DEPEND="chromeos-base/libchrome
	dev-libs/vectormath
	${RDEPEND}"

# Print the number of jobs from $MAKEOPTS.
print_num_jobs() {
	local JOBS=$(echo $MAKEOPTS | sed -nre 's/.*-j\s*([0-9]+).*/\1/p')
	echo ${JOBS:-1}
}

src_unpack() {
	local platform="${CHROMEOS_ROOT}/src/platform/"
	elog "Using platform dir: $platform"
	mkdir -p "${S}/window_manager"
	cp -a "${platform}"/window_manager/* "${S}/window_manager" || die
	# TODO: It'd be better if libcros installed its headers so we could pull
	# them from /usr/include instead of copying over the one we want.
	mkdir -p "${S}/cros"
	cp "${platform}"/cros/chromeos_wm_ipc_enums.h "${S}/cros" || die
}

src_compile() {
	tc-export CC CXX AR RANLIB LD NM
	CFLAGS="${CFLAGS} -ggdb"
	export CCFLAGS="$CFLAGS"

	local backend
	if use opengles ; then
		backend=OPENGLES
	else
		backend=OPENGL
	fi

	# TODO: breakpad should have its own ebuild and we should add to
	# hard-target-depends. Perhaps the same for src/third_party/chrome
	# and src/common
	pushd "window_manager"
	scons BACKEND="$backend" -j$(print_num_jobs) wm screenshot || \
		die "window_manager compile failed"
	${CHROMEOS_ROOT}/src/platform/crash/dump_syms.i386 wm > wm.sym \
	        2>/dev/null || die "symbol extraction failed"
	popd
}

src_test() {
	tc-export CC CXX AR RANLIB LD NM
	export CCFLAGS="$CFLAGS"

	pushd "window_manager"
	scons -j$(print_num_jobs) tests || die "failed to build tests"
	popd

	if ! use x86 ; then
		echo Skipping tests on non-x86 platform...
	else
		pushd "window_manager"
		for test in ./*_test; do
			"$test" ${GTEST_ARGS} || die "$test failed"
		done
		popd
	fi
}

src_install() {
	newbin window_manager/wm chromeos-wm
	dobin window_manager/screenshot
	dobin window_manager/bin/cros-term
	dobin window_manager/bin/crosh
	dobin window_manager/bin/crosh-dev
	dobin window_manager/bin/crosh-usb

	into /
	dosbin window_manager/bin/window-manager-session.sh

	insinto /usr/lib/debug
	doins window_manager/wm.sym
}
