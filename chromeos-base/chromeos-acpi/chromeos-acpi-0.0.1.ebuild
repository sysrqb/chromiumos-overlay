# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs

DESCRIPTION="Chrome OS ACPI Scripts"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND=""

RDEPEND="sys-power/acpid"

src_unpack() {
  local acpi="${CHROMEOS_ROOT}/src/platform/acpi"
  elog "Using acpi: $acpi"
  mkdir "${S}"
  cp -a "${acpi}"/* "${S}" || die
}

src_install() {
  dodir /etc/acpi/events
  dodir /etc/acpi

  install -m 0755 -o root -g root "${S}"/event_* "${D}"/etc/acpi/events
  install -m 0755 -o root -g root "${S}"/action_* "${D}"/etc/acpi
}
