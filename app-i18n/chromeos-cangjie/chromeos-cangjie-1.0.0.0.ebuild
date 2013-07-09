# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
inherit eutils

DESCRIPTION="The Chinese Cangjie input engine for IME extension API."
HOMEPAGE="https://code.google.com/p/google-input-tools/"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 x86 arm"
S="${WORKDIR}/${PN}"

src_prepare() {
  epatch "${FILESDIR}"/${P}-insert-public-key.patch
}

src_install() {
  insinto /usr/share/chromeos-assets/input_methods/cangjie
  doins -r *
}
