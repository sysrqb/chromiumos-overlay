# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/third_party/glmark2"

inherit toolchain-funcs waf-utils cros-workon

DESCRIPTION="Opengl test suite"
HOMEPAGE="https://launchpad.net/glmark2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="gles2 drm"

RDEPEND="media-libs/libpng
	media-libs/mesa[gles2?]
	x11-libs/libX11"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_prepare() {
	rm -rf src/libpng
	sed -i -e 's:libpng12:libpng:g' wscript src/wscript_build || die
}

src_configure() {
	local myconf="--enable-gl"

	if use gles2; then
		myconf+=" --enable-glesv2"
	fi

	if use drm; then
		myconf+=" --enable-gl-drm"
		if use gles2; then
			myconf+=" --enable-glesv2-drm"
		fi
	fi

	export PKGCONFIG=$(tc-getPKG_CONFIG)
	waf-utils_src_configure ${myconf}
}
