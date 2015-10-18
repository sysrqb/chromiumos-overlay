# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="b55097ce8ac75efb16af3c0c0f32673b6d1b9451"
CROS_WORKON_TREE="d1676955bee3c7fd3e0f437aa8c4eb880412e89b"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_NATIVE_TEST="yes"
PLATFORM_SUBDIR="login_manager"
PLATFORM_GYP_FILE="${PN}.gyp"

inherit cros-workon platform

DESCRIPTION="Session manager (chromeos-login) DBus client library for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host"

DEPEND="
	cros_host? ( chromeos-base/chromeos-dbus-bindings )
"

RDEPEND="
	!<chromeos-base/chromeos-login-0.0.2
"

src_install() {
	# Install DBus client library.
	platform_install_dbus_client_lib "session_manager"
}