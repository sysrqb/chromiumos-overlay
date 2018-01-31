# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
MY_PV="${PV}"
MY_PF="${PN}-${MY_PV}"

DESCRIPTION="Chromium Crouton extention for XiWi (X11-in-Window)"
HOMEPAGE=""
SRC_URI=""
SRC_URI="https://github.com/sysrqb/torsocks/archive/authenticated_downoloads.tar.gz -> ${MY_PF}.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_install() {
	
