# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"

inherit cros-workon autotest-deponly

DESCRIPTION="Autotest common deps"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~arm ~amd64"

# Autotest enabled by default.
IUSE="+autotest"

CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

# following deps don't compile: boottool, mysql, pgpool, pgsql, systemtap, # dejagnu, libcap, libnet
# following deps are not deps: factory
# following tests are going to be moved: chrome_test
AUTOTEST_DEPS_LIST="fio gtest hdparm ibusclient iwcap realtimecomm_playground sysstat test_tones fakegudev fakemodem"
AUTOTEST_CONFIG_LIST=*
AUTOTEST_PROFILERS_LIST=*

# NOTE: For deps, we need to keep *.a
AUTOTEST_FILE_MASK="*.tar.bz2 *.tbz2 *.tgz *.tar.gz"

# deps/gtest
RDEPEND="
  dev-cpp/gtest
"

RDEPEND="${RDEPEND}
  chromeos-base/autotest-deps-libaio
"

# deps/chrome_test
#RDEPEND="${RDEPEND}
#  chromeos-base/chromeos-chrome
#"

# deps/ibusclient
RDEPEND="${RDEPEND}
  app-i18n/ibus
  dev-libs/glib
  sys-apps/dbus
"

# deps/iwcap
RDEPEND="${RDEPEND}
  dev-libs/libnl
"

# deps/fakegudev
RDEPEND="${RDEPEND}
  sys-fs/udev[gudev]
"

# deps/fakemodem
RDEPEND="${RDEPEND}
  chromeos-base/autotest-fakemodem-conf
"

DEPEND="${RDEPEND}"

