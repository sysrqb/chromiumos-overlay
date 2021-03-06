# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-wireless/bluez/bluez-4.99.ebuild,v 1.7 2012/04/15 16:53:41 maekke Exp $

EAPI="4"
CROS_WORKON_COMMIT="ad47762c23d1b13c272eac064d5278483c305064"
CROS_WORKON_TREE="ec2af85396af6b77dff0f08451aa99a644bc2f71"
PYTHON_DEPEND="test-programs? 2"
CROS_WORKON_PROJECT="chromiumos/third_party/bluez"

inherit autotools multilib eutils systemd python udev user cros-workon

DESCRIPTION="Bluetooth Tools and System Daemons for Linux"
HOMEPAGE="http://www.bluez.org/"
#SRC_URI not defined because we get our source locally

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="cups debug test-programs readline"

CDEPEND="
	>=dev-libs/glib-2.14:2
	sys-apps/dbus
	virtual/udev
	cups? ( net-print/cups )
	readline? ( sys-libs/readline )
"
DEPEND="${CDEPEND}
	>=dev-util/pkgconfig-0.20
	sys-devel/flex
	test-programs? ( >=dev-libs/check-0.9.8 )
"
RDEPEND="${CDEPEND}
	!net-wireless/bluez-hcidump
	!net-wireless/bluez-libs
	!net-wireless/bluez-test
	!net-wireless/bluez-utils
	test-programs? (
		dev-python/dbus-python
		dev-python/pygobject:2
	)
"

DOCS=( AUTHORS ChangeLog README )

pkg_setup() {
	if use test-programs; then
		python_pkg_setup
	fi
}

src_prepare() {
	eautoreconf

	if use cups; then
		sed -i \
			-e "s:cupsdir = \$(libdir)/cups:cupsdir = `cups-config --serverbin`:" \
			Makefile.tools Makefile.in || die
	fi
}

src_configure() {
	use readline || export ac_cv_header_readline_readline_h=no

	econf \
		--enable-tools \
		--localstatedir=/var \
		$(use_enable cups) \
		--enable-datafiles \
		$(use_enable debug) \
		$(use_enable test-programs test) \
		--enable-library \
		--disable-systemd \
		--disable-obex \
		--enable-sixaxis
}

src_test() {
	# TODO(armansito): Run unit tests for non-x86 platforms.
	# TODO(armansito): Instead of running dbus-launch here, use
	# dbus-run-session from within BlueZ's make target and get that
	# upstream. We're taking this approach for now since dbus-run-session
	# requires at least dbus-1.8.
	[[ "${ARCH}" == "x86" || "${ARCH}" == "amd64" ]] && \
		dbus-launch --exit-with-session emake check
}

src_install() {
	default

	if use test-programs ; then
		cd "${S}/test"
		dobin simple-agent simple-endpoint simple-player simple-service
		dobin monitor-bluetooth
		newbin list-devices list-bluetooth-devices
		local b
		for b in test-* ; do
			newbin "${b}" "bluez-${b}"
		done
		insinto /usr/share/doc/${PF}/test-services
		doins service-*

		python_convert_shebangs -r 2 "${ED}"
		cd "${S}"
	fi

	dobin tools/btmgmt tools/btgatt-client tools/btgatt-server

	insinto /etc/init
	newins "${FILESDIR}/${PN}-upstart.conf" bluetoothd.conf

	udev_dorules "${FILESDIR}/99-uhid.rules"
	udev_dorules "${FILESDIR}/99-ps3-gamepad.rules"

	# We don't preserve /var/lib in images, so nuke anything we preseed.
	rm -rf "${D}"/var/lib/bluetooth

	rm "${D}/lib/udev/rules.d/97-bluetooth.rules"

	find "${D}" -name "*.la" -delete
}

pkg_postinst() {
	enewuser "bluetooth" "218"
	enewgroup "bluetooth" "218"

	udev_reload

	if ! has_version "net-dialup/ppp"; then
		elog "To use dial up networking you must install net-dialup/ppp."
	fi

	if [ "$(rc-config list default | grep bluetooth)" = "" ] ; then
		elog "You will need to add bluetooth service to default runlevel"
		elog "for getting your devices detected from startup without needing"
		elog "to reconnect them. For that please run:"
		elog "'rc-update add bluetooth default'"
	fi
}
