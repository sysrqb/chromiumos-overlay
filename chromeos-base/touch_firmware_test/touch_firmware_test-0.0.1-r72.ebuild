# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="16eecd7e510f1fc4fa2f757b4d551f005c877a74"
CROS_WORKON_TREE="f8a387eed094b86faa0e08daeb1638e8926ade2f"
CROS_WORKON_PROJECT="chromiumos/platform/touch_firmware_test"

PYTHON_COMPAT=( python2_7 )
inherit cros-workon cros-constants cros-debug distutils-r1

DESCRIPTION="Chromium OS multitouch utilities"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

RDEPEND=""

DEPEND=${RDEPEND}

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	cros-workon_src_configure
}

src_install() {
	# install the remote package
	distutils-r1_src_install

	# install the webplot script
	exeinto /usr/local/bin
	newexe webplot/chromeos_wrapper.sh webplot

	# install to autotest deps directory for dependency
	DESTDIR="${D}${AUTOTEST_BASE}/client/deps/touchpad-tests/touch_firmware_test"
	mkdir -p "${DESTDIR}"
	echo "CMD:" cp -Rp "${S}"/* "${DESTDIR}"
	cp -Rp "${S}"/* "${DESTDIR}"
}