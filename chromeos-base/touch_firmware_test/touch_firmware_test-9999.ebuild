# Copyright (c) 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_PROJECT="chromiumos/platform/touch_firmware_test"

inherit cros-workon cros-constants cros-debug

DESCRIPTION="Chromium OS multitouch utilities"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~*"
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
	# install to autotest deps directory for dependency
	DESTDIR="${D}${AUTOTEST_BASE}/client/deps/touch_firmware_test"
	mkdir -p "${DESTDIR}"
	echo "CMD:" cp -Rp "${S}"/* "${DESTDIR}"
	cp -Rp "${S}"/* "${DESTDIR}"
}