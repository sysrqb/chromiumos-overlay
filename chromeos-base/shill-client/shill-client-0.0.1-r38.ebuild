# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT=("b326ee2fd5e338f3615064525c8007d4fd546708" "c08d8a9193703486ef89bb9cc2e8e624d223088c")
CROS_WORKON_TREE=("83516578dcced47fa87563f99e4e8571c9f4000b" "e713d31132fddd7b265fcc7773274cf72dfcfbd6")
CROS_WORKON_BLACKLIST=1
CROS_WORKON_LOCALNAME=("platform2" "aosp/system/connectivity/shill")
CROS_WORKON_PROJECT=("chromiumos/platform2" "platform/system/connectivity/shill")
CROS_WORKON_REPO=("https://chromium.googlesource.com" "https://android.googlesource.com")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/aosp/system/connectivity/shill")
CROS_WORKON_INCREMENTAL_BUILD=1

PLATFORM_NATIVE_TEST="yes"
PLATFORM_SUBDIR="${PN%-client}"
PLATFORM_GYP_FILE="${PN}.gyp"

inherit cros-workon platform

DESCRIPTION="Shill DBus client library for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host"

# D-Bus proxies generated by this client library depend on the code generator
# itself (chromeos-dbus-bindings) and produce header files that rely on
# libbrillo library, hence both dependencies. We require the particular
# revision because libbrillo-0.0.1-r1 changed location of header files from
# chromeos/ to brillo/ and chromeos-dbus-bindings-0.0.1-r1058 generates the
# code using the new location.
DEPEND="
	cros_host? ( >=chromeos-base/chromeos-dbus-bindings-0.0.1-r1058 )
	>=chromeos-base/libbrillo-0.0.1-r1
"

RDEPEND="
	!<chromeos-base/shill-0.0.2
"

src_unpack() {
	local s="${S}"
	platform_src_unpack
	S="${s}/aosp/system/connectivity/shill"
}

src_install() {
	# Install DBus client library.
	platform_install_dbus_client_lib "shill"

	# Install dbus-c++ client library.
	insinto /usr/include/shill-client/shill/dbus_proxies
	doins ${OUT}/gen/include/shill/dbus_proxies/*.h
}