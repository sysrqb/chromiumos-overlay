# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="5cc5341ba65bdbc088cb6d98e64dd307e28240b4"
CROS_WORKON_TREE="867cc47cb55eb87c44706b2b3ba7df64316afaa5"
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
IUSE="examples wifi_bootstrapping"

COMMON_DEPEND="
	chromeos-base/libchromeos
	chromeos-base/libweave
	chromeos-base/webserver
"

RDEPEND="
	${COMMON_DEPEND}
	wifi_bootstrapping? (
		chromeos-base/apmanager
		chromeos-base/peerd
	)
"

DEPEND="
	${COMMON_DEPEND}
	test? (
		dev-cpp/gmock
		dev-cpp/gtest
	)
"

pkg_preinst() {
	# Create user and group for buffet.
	enewuser "buffet"
	enewgroup "buffet"
	# Additional groups to put buffet into.
	enewgroup "apmanager"
	enewgroup "peerd"
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
	if ! use wifi_bootstrapping ; then
		sed -i 's/\(BUFFET_DISABLE_PRIVET=\).*$/\1true/g' \
			"${ED}"/etc/init/buffet.conf
	fi

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