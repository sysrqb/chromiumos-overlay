# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="01287957d1e40d5e9c1721da037e099ec07539ff"
CROS_WORKON_TREE="92cd68ed6045c00249756148aa40e50a8324eaef"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="settingsd"

inherit cros-workon libchrome platform

DESCRIPTION="Device Configuration Management Services"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD-Google"
SLOT=0
KEYWORDS="*"

DEPEND="
	test? ( dev-cpp/gtest )
"

platform_pkg_test() {
	local tests=(
		settingsd_testrunner
	)

	local test_bin
	for test_bin in "${tests[@]}"; do
		platform_test "run" "${OUT}/${test_bin}"
	done
}