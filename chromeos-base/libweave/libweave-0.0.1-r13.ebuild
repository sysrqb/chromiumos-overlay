# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_COMMIT="7d29a1ee6d5165ee829ccd4d5b195f5ee4eef151"
CROS_WORKON_TREE="8c32fa617bd0ee05b6a0c9fdee205fa6234885cd"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="libweave"

inherit cros-workon libchrome platform

DESCRIPTION="Weave device library"
HOMEPAGE="http://dev.chromium.org/chromium-os/platform"
LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

COMMON_DEPEND="
  chromeos-base/libchromeos
"

RDEPEND="
  ${COMMON_DEPEND}
"

DEPEND="
  ${COMMON_DEPEND}
  dev-cpp/gmock
  dev-cpp/gtest
"

src_install() {
  insinto "/usr/$(get_libdir)/pkgconfig"

  # Install libraries.
  local v
  for v in "${LIBCHROME_VERS[@]}"; do
    ./platform2_preinstall.sh "${OUT}" "${v}"
    dolib.so "${OUT}"/lib/libweave-"${v}".so
    doins "${OUT}"/lib/libweave-*"${v}".pc
    dolib.a "${OUT}"/libweave-test-"${v}".a
  done

  # Install header files.
  insinto /usr/include/weave
  doins include/weave/*.h
}

platform_pkg_test() {
  platform_test "run" "${OUT}/libweave_testrunner"
}