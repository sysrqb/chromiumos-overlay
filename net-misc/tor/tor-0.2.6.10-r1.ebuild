# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

inherit autotools cros-board eutils flag-o-matic versionator user

MY_PV="$(replace_version_separator 4 -)"
MY_PF="${PN}-${MY_PV}"
DESCRIPTION="Anonymizing overlay network for TCP"
HOMEPAGE="https://www.torproject.org/"
SRC_URI="https://www.torproject.org/dist/${MY_PF}.tar.gz
	https://archive.torproject.org/tor-package-archive/${MY_PF}.tar.gz"
#S="${WORKDIR}/${MY_PF}"

LICENSE="BSD GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="-bufferevents nat-pmp scrypt +seccomp selinux stats -systemd +tor-hardening transparent-proxy test upnp web"

DEPEND="dev-libs/openssl:=
	sys-libs/zlib
	dev-libs/libevent
	bufferevents? ( dev-libs/libevent[ssl] )
	nat-pmp? ( net-libs/libnatpmp )
	scrypt? ( app-crypt/libscrypt )
	seccomp? ( sys-libs/libseccomp )
	systemd? ( sys-apps/systemd )
	upnp? ( net-libs/miniupnpc )"
RDEPEND="${DEPEND}
	selinux? ( sec-policy/selinux-tor )"

pkg_setup() {
	enewgroup tor
	enewuser tor -1 -1 /var/lib/tor tor
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-0.2.3.14_alpha-torrc.sample.patch
	# See https://github.com/libevent/libevent/pull/142
	epatch "${FILESDIR}"/${PN}-0.2.6.10-configure-libevent-with-pkg-config.patch
	WANT_AUTOCONF="" autoreconf
	epatch_user
}

src_configure() {
	# Upstream isn't sure of all the user provided CFLAGS that
	# will break tor, but does recommend against -fstrict-aliasing.
	# We'll filter-flags them here as we encounter them.
	filter-flags -fstrict-aliasing

	#local BOARD=$(get_current_board_with_variant)

	#if [[ -z "${BOARD}" ]]; then
	#	die "Could not determine the current board using cros-board.eclass."
	#fi

	econf \
		--enable-system-torrc \
		--enable-asciidoc \
		--docdir=/usr/share/doc/${PF} \
		$(use_enable stats instrument-downloads) \
		$(use_enable bufferevents) \
		$(use_enable nat-pmp) \
		$(use_enable scrypt libscrypt) \
		$(use_enable seccomp) \
		$(use_enable systemd) \
		$(use_enable tor-hardening gcc-hardening) \
		$(use_enable tor-hardening linker-hardening) \
		$(use_enable transparent-proxy transparent) \
		$(use_enable upnp) \
		$(use_enable web tor2web-mode) \
		$(use_enable test unittests) \
		$(use_enable test coverage)
}

src_install() {
	emake

	insinto /etc/tor/
	doins "${FILESDIR}"/torrc

	insinto /etc/init/
	doins "${FILESDIR}"/tor.conf

	insinto /usr/share/tor
    doins ${S}/src/config/geoip ${S}/src/config/geoip6

	into /usr
	dobin ${S}/src/or/tor ${S}/src/tools/tor-resolve
}