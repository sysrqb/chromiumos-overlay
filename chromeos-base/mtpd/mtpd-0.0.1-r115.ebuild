# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="ef2d18d7094d1186685420feaf99778c60731a11"
CROS_WORKON_TREE="1e2e727ef5a4411f013430a7658d5c69b830d447"
CROS_WORKON_PROJECT="chromiumos/platform/mtpd"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-debug cros-workon libchrome user

DESCRIPTION="MTP daemon for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang +seccomp test"
REQUIRED_USE="asan? ( clang )"

RDEPEND="
	chromeos-base/libbrillo
	dev-libs/dbus-c++
	>=dev-libs/glib-2.30
	dev-libs/protobuf
	media-libs/libmtp
	virtual/udev
"

DEPEND="${RDEPEND}
	chromeos-base/system_api
	test? ( dev-cpp/gtest )"

src_prepare() {
	cros-workon_src_prepare
}

src_configure() {
	clang-setup-env
	cros-workon_src_configure
}

src_compile() {
	cros-workon_src_compile
}

src_test() {
	if ! use x86 && ! use amd64 ; then
		einfo Skipping unit tests on non-x86 platform
	else
		# Needed for `cros_run_unit_tests`.
		cros-workon_src_test
	fi
}

src_install() {
	cros-workon_src_install
	exeinto /opt/google/mtpd
	doexe "${OUT}"/mtpd

	# Install seccomp policy file.
	insinto /opt/google/mtpd
	use seccomp && newins "mtpd-seccomp-${ARCH}.policy" mtpd-seccomp.policy

	# Install upstart config file.
	insinto /etc/init
	doins mtpd.conf

	# Install D-Bus config file.
	insinto /etc/dbus-1/system.d
	doins org.chromium.Mtpd.conf
}

pkg_preinst() {
	enewuser "mtp"
	enewgroup "mtp"
}