# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
# $Header: $

# @ECLASS: crashid.eclass
# @MAINTAINER:
# Chromium OS crash reporter maintainers; see src/platform/crash-reporter/OWNERS
# @BUGREPORTS:
# Please report bugs via http://crbug.com/new (with label Build)
# @VCSURL: https://chromium.googlesource.com/chromiumos/overlays/chromiumos-overlay/+/master/eclass/@ECLASS@
# @BLURB: Eclass for setting up GOOGLE_CRASH_ID and GOOGLE_CRASH_VERSION_ID in /etc/os-release
#
# @FUNCTION: docrashid
# @USAGE: <crash_id> [<crash_version_id>]
# @DESCRIPTION:
# Initializes /etc/os-release with the crash id and crash version (optional).
# Both the crash id and version are restricted to [a-zA-Z.-_].
# @CODE
# docrashid chromeos first_version
# @CODE
# will add
# @CODE
# GOOGLE_CRASH_ID=chromeos
# GOOGLE_CRASH_VERSION_ID=first_version
# @CODE
# to /etc/os-release.
docrashid() {
	[[ $# -lt 3 && $# -gt 0 && -n $1 ]] || die "Usage: ${FUNCNAME} <crash_id> [<crash_version_id>]"
	local validregex="[-._a-zA-Z]+"
	local crash_id="$1"
	local crash_version_id="$2"
	local filtered_id=$(echo "${crash_id}" | \
		LC_ALL=C sed -r "s:${validregex}::")
	local filtered_version_id=$(echo "${crash_version_id}" | \
		LC_ALL=C sed -r "s:${validregex}::")
	if [[ -n ${filtered_id} || -n ${filtered_version_id} ]]; then
		die "Invalid input. Must satisfy: ${validregex}"
	fi
	dodir /etc

	local os_release="${D}/etc/os-release"
	[[ -e ${os_release} ]] && die "${os_release} already exists!"

	echo "GOOGLE_CRASH_ID=${crash_id}" > "${os_release}" || die "creating ${os_release} failed!"
	if [[ -n "${crash_version_id}" ]]; then
		echo "GOOGLE_CRASH_VERSION_ID=${crash_version_id}" >> "${os_release}"
	fi
}
