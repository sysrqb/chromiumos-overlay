# Copyright 2012 The Chromium OS Authors
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="4"
CROS_WORKON_COMMIT="b7109c8c4b2fc29f57cc483ce099fe4d3da98702"
CROS_WORKON_TREE="a2f088a30911840d4b76d930bda947feed940958"
CROS_WORKON_PROJECT="chromiumos/third_party/coreboot"
CROS_WORKON_LOCALNAME="coreboot"

inherit cros-workon toolchain-funcs

RDEPEND="sys-apps/pciutils"
DEPEND="${RDEPEND}"

DESCRIPTION="Utilities for modifying coreboot firmware images"
HOMEPAGE="http://coreboot.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"

src_configure() {
	cros-workon_src_configure
}

is_x86() {
	use x86 || use amd64
}

src_compile() {
	tc-export CC
	# These two utilities are used on the host
	tc-env_build emake -C util/cbfstool
	if is_x86; then
		tc-env_build emake -C util/ifdtool
	fi

	# And these are used in the image
	if is_x86; then
		emake -C util/superiotool CC="${CC}"
		emake -C util/inteltool CC="${CC}"
		emake -C util/nvramtool CC="${CC}"
	fi
}

src_install() {
	dobin util/cbfstool/cbfstool
	if is_x86; then
		dobin util/ifdtool/ifdtool
		dobin util/superiotool/superiotool
		dobin util/inteltool/inteltool
		dobin util/nvramtool/nvramtool
	fi
}

pkg_preinst() {
	# TODO(reinauer) This is an ugly workaround to have the utilities
	# live outside the /build directory.
	# The package will never be installed to the image.
	mv $D/usr/bin/cbfstool /usr/bin
	if is_x86; then
		mv $D/usr/bin/ifdtool /usr/bin
	fi
}
