# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT=("2e2317a3319afee2342cd19fe9fdaa3412b1f4d3" "238da575cbad80fb7ffb0e89b9ccb33c7889a0ba")
CROS_WORKON_TREE=("1e63372f360b9280dacd119c9061786bdfbc6d83" "79ead835f4ad6df05877ef0d26af193346cbb1d1")
CROS_WORKON_BLACKLIST=1
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_USE_VCSID=1
CROS_WORKON_LOCALNAME=("platform2" "aosp/external/libchromeos")
CROS_WORKON_PROJECT=("chromiumos/platform2" "platform/external/libchromeos")
CROS_WORKON_REPO=("https://chromium.googlesource.com" "https://android.googlesource.com")
CROS_WORKON_DESTDIR=("${S}/platform2" "${S}/platform2/libchromeos")

PLATFORM_SUBDIR="libchromeos"
PLATFORM_NATIVE_TEST="yes"

inherit cros-workon libchrome multilib platform

DESCRIPTION="Base library for Chromium OS"
HOMEPAGE="http://dev.chromium.org/chromium-os/platform"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="cros_host"

COMMON_DEPEND="
	chromeos-base/bootstat
	chromeos-base/chromeos-minijail
	dev-libs/dbus-c++
	dev-libs/dbus-glib
	dev-libs/openssl
	dev-libs/protobuf
	net-misc/curl
	sys-apps/rootdev
"
RDEPEND="
	${COMMON_DEPEND}
	!cros_host? ( chromeos-base/libchromeos-use-flags )
	chromeos-base/chromeos-ca-certificates
"
DEPEND="
	${COMMON_DEPEND}
	chromeos-base/protofiles
	dev-cpp/gtest
	dev-libs/modp_b64
	test? (
		app-shells/dash
		dev-cpp/gmock
	)
"

src_install() {
	local v
	insinto "/usr/$(get_libdir)/pkgconfig"
	for v in "${LIBCHROME_VERS[@]}"; do
		./platform2_preinstall.sh "${OUT}" "${v}"
		dolib.so "${OUT}"/lib/lib{chromeos,policy}*-"${v}".so
		dolib.a "${OUT}"/libchromeos*-"${v}".a
		doins "${OUT}"/lib/libchromeos*-"${v}".pc
	done

	# Install all the header files from libchromeos/chromeos/*.h into
	# /usr/include/chromeos (recursively, with sub-directories).
	# Exclude the following sub-directories though (they are handled separately):
	#   chromeos/policy
	local dir
	while read -d $'\0' -r dir; do
		insinto "/usr/include/${dir}"
		doins "${dir}"/*.h
	done < <(find chromeos -type d -not -path "chromeos/policy*" -print0)

	insinto /usr/include/policy
	doins chromeos/policy/*.h
}

platform_pkg_test() {
	local v
	for v in "${LIBCHROME_VERS[@]}"; do
		platform_test "run" "${OUT}/libchromeos-${v}_unittests"
		platform_test "run" "${OUT}/libpolicy-${v}_unittests"
	done
}