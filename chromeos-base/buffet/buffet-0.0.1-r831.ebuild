# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="a16566a59c57ef76ee8b0a4dd18722e6839a50a6"
CROS_WORKON_TREE="d856ca4faf9387634a60c234cf8b90ba5f0b36f7"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="buffet"

inherit cros-workon libchrome platform user

DESCRIPTION="Local and cloud communication services for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"
IUSE="examples"

RDEPEND="
	chromeos-base/libchromeos
"

DEPEND="
	${RDEPEND}
	test? ( dev-cpp/gmock )
	dev-cpp/gtest
"

pkg_preinst() {
	# Create user and group for buffet.
	enewuser "buffet"
	enewgroup "buffet"
}

src_install_test_daemon() {
	dobin "${OUT}"/buffet_test_daemon

	# Base GCD command and state definitions.
	insinto /etc/buffet/commands
	doins etc/buffet/commands/test.json
}

src_install() {
	insinto "/usr/$(get_libdir)/pkgconfig"

	dobin "${OUT}"/buffet
	dobin "${OUT}"/buffet_client

	# DBus configuration.
	insinto /etc/dbus-1/system.d
	doins etc/dbus-1/org.chromium.Buffet.conf

	# Base GCD command and state definitions.
	insinto /etc/buffet
	doins etc/buffet/*

	# GCD command implemented by buffet.
	insinto /etc/buffet/commands
	doins etc/buffet/commands/buffet.json

	# Upstart script.
	insinto /etc/init
	doins etc/init/buffet.conf

	if use examples ; then
		src_install_test_daemon
	fi
}

platform_pkg_test() {
	local tests=(
		buffet_testrunner
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}