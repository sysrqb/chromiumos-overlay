# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-plugins/adobe-flash/adobe-flash-11.0.1.152.ebuild,v 1.2 2011/10/05 12:32:41 scarabeus Exp $

EAPI=4
inherit nsplugins multilib toolchain-funcs versionator

MY_32B_URI="http://fpdownload.macromedia.com/get/flashplayer/pdc/${PV}/install_flash_player_$(get_major_version)_linux.i386.tar.gz -> ${P}.i386.tar.gz"
MY_64B_URI="http://fpdownload.macromedia.com/get/flashplayer/pdc/${PV}/install_flash_player_$(get_major_version)_linux.x86_64.tar.gz -> ${P}.x86_64.tar.gz"

DESCRIPTION="Adobe Flash Player"
SRC_URI="x86? ( ${MY_32B_URI} )
amd64? (
	multilib? (
		32bit? ( ${MY_32B_URI} )
		64bit? ( ${MY_64B_URI} )
	)
	!multilib? ( ${MY_64B_URI} )
)"
HOMEPAGE="http://www.adobe.com/products/flashplayer.html"
IUSE="multilib +32bit +64bit vdpau bindist kde"
SLOT="0"

KEYWORDS="-* amd64 x86"
LICENSE="AdobeFlash-11_beta"
RESTRICT="strip mirror"

S="${WORKDIR}"

# >glibc-2.4 dependency is removed to workaround bug in gmerge.
# See http://crosbug.com/9991
NATIVE_DEPS="x11-libs/gtk+:2
	media-libs/fontconfig
	dev-libs/nss
	net-misc/curl
	vdpau? ( x11-libs/libvdpau )
	kde? ( kde-base/kcmshell )"

EMUL_DEPS="vdpau? ( >=app-emulation/emul-linux-x86-xlibs-20110129 )
	>=app-emulation/emul-linux-x86-gtklibs-20100409-r1
	app-emulation/emul-linux-x86-soundlibs"

DEPEND="amd64? ( multilib? ( !64bit? ( www-plugins/nspluginwrapper ) ) )"
RDEPEND="x86? ( $NATIVE_DEPS )
	amd64? (
		multilib? (
			64bit? ( $NATIVE_DEPS )
			32bit? ( $EMUL_DEPS )
		)
		!multilib? ( $NATIVE_DEPS )
	)
	|| ( media-fonts/liberation-fonts media-fonts/corefonts )
	${DEPEND}"

# Chromium expects that flash is installed to /opt/netscape/plugins.
INSTALL_BASE="opt/netscape/plugins"

# Ignore QA warnings in these closed-source binaries, since we can't fix them:
QA_PREBUILT="opt/*"

pkg_setup() {
	if use x86; then
		export native_install=1
	elif use amd64; then
		# amd64 users may unselect the native 64bit binary, if they choose
		if ! use multilib || use 64bit; then
			export native_install=1
		else
			unset native_install
		fi

		if use multilib && use 32bit; then
			export amd64_32bit=1
		else
			unset amd64_32bit
		fi

		if use multilib && ! use 32bit && ! use 64bit; then
			eerror "You must select at least one architecture USE flag (32bit or 64bit)"
			die "No library version selected [-32bit -64bit]"
		fi

		unset need_lahf_wrapper
		if [[ $native_install ]]; then
			# 64bit flash requires the 'lahf' instruction (bug #268336)
			# Also, check if *any* of the processors are affected (bug #286159)
			if grep '^flags' /proc/cpuinfo | grep -qv 'lahf_lm'; then
				export need_lahf_wrapper=1
			fi
		fi
	fi
}

src_unpack() {
	if [[ $amd64_32bit ]]; then
		# Since the 32-bit and 64-bit tarballs collide, put the 32-bit one
		# elsewhere:
		local my_32b_src=${MY_32B_URI##*>}
		local my_64b_src=${MY_64B_URI##*>}
		if [[ $native_install ]]; then
			unpack $my_64b_src
		fi
		mkdir 32bit
		pushd 32bit >/dev/null
		unpack $my_32b_src
		popd >/dev/null
	else
		default_src_unpack
	fi
}

src_compile() {
	if [[ $need_lahf_wrapper ]]; then
		# This experimental wrapper, from Maks Verver via bug #268336 should
		# emulate the missing lahf instruction affected platforms.
		$(tc-getCC) -fPIC -shared -nostdlib -lc -oflashplugin-lahf-fix.so \
			"${FILESDIR}/flashplugin-lahf-fix.c" \
			|| die "Compile of flashplugin-lahf-fix.so failed"
	fi
}

src_install() {
	if [[ $native_install ]]; then
		BASE=${INSTALL_BASE}

		# The plugin itself
		exeinto /${BASE}
		doexe libflashplayer.so
		inst_plugin /${BASE}/libflashplayer.so
	fi

	if [[ $need_lahf_wrapper ]]; then
		# This experimental wrapper, from Maks Verver via bug #268336 should
		# emulate the missing lahf instruction affected platforms.
		exeinto /${INSTALL_BASE}
		doexe flashplugin-lahf-fix.so
		inst_plugin /${INSTALL_BASE}/flashplugin-lahf-fix.so
	fi

	if [[ $amd64_32bit ]]; then
		# Only install the plugin, nothing else for 32-bit.
		local oldabi="${ABI}"
		ABI="x86"

		# 32b plugin
		pushd "${S}/32bit"
			exeinto /${INSTALL_BASE}32
			doexe libflashplayer.so
			inst_plugin /${INSTALL_BASE}32/libflashplayer.so
		popd

		ABI="${oldabi}"
	fi

	# The magic config file!
	insinto "/etc/adobe"
	doins "${FILESDIR}/mms.cfg"
}

pkg_postinst() {
	if use amd64; then
		if [[ $need_lahf_wrapper ]]; then
			ewarn "Your processor does not support the 'lahf' instruction which is used"
			ewarn "by Adobe's 64-bit flash binary.  We have installed a wrapper which"
			ewarn "should allow this plugin to run.  If you encounter problems, please"
			ewarn "adjust your USE flags to install only the 32-bit version and reinstall:"
			ewarn "  ${CATEGORY}/$PN[+32bit -64bit]"
			elog
		fi
		if has_version 'www-plugins/nspluginwrapper'; then
			if [[ $native_install ]]; then
				# TODO: Perhaps parse the output of 'nspluginwrapper -l'
				#       However, the 64b flash plugin makes
				#       'nspluginwrapper -l' segfault.
				local FLASH_WRAPPER="${ROOT}/usr/lib64/nsbrowser/plugins/npwrapper.libflashplayer.so"
				if [[ -f ${FLASH_WRAPPER} ]]; then
					einfo "Removing duplicate 32-bit plugin wrapper: Native 64-bit plugin installed"
					nspluginwrapper -r "${FLASH_WRAPPER}"
				fi
			else
				einfo "nspluginwrapper detected: Installing plugin wrapper"
				local oldabi="${ABI}"
				ABI="x86"
				local FLASH_SOURCE="${ROOT}/${INSTALL_BASE}32/libflashplayer.so"
				nspluginwrapper -i "${FLASH_SOURCE}"
				ABI="${oldabi}"
			fi
		elif [[ ! $native_install ]]; then
			elog "To use the 32-bit flash player in a native 64-bit browser,"
			elog "you must install www-plugins/nspluginwrapper"
		fi
	fi

	ewarn "Flash player is closed-source, with a long history of security"
	ewarn "issues.  Please consider only running flash applets you know to"
	ewarn "be safe.  The 'flashblock' extension may help for mozilla users:"
	ewarn "  https://addons.mozilla.org/en-US/firefox/addon/433"
}
