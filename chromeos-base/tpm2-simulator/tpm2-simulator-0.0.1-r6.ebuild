# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="d2e0c611db71a970bbb1ef7c1cb07ed15d3a9e4d"
CROS_WORKON_TREE="aae006ac6de12ab765cfb2ae61e5fa2fe2d0be82"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="tpm2-simulator"

inherit cros-workon platform user

DESCRIPTION="TPM 2.0 Simulator"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	dev-libs/openssl
	chromeos-base/tpm2
	chromeos-base/libchromeos
	"

DEPEND="
	${RDEPEND}
	"

src_install() {
	dobin "${OUT}"/tpm2-simulator
}