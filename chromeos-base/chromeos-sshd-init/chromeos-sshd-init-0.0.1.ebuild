# Copyright 2014 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI="4"

DESCRIPTION="Install Chromium OS sshd Upstart file to a shared location."
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

S="${WORKDIR}"

src_install() {
	insinto /usr/share/chromeos-ssh-config/init
	doins "${FILESDIR}"/*.conf
}
