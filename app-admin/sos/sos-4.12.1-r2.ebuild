# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 shell-completion

DESCRIPTION="Collect system configuration and diagnostic information"
HOMEPAGE="https://github.com/sosreport/sos https://sos.readthedocs.io/"
SRC_URI="https://deb.debian.org/debian/pool/main/s/sos/sos_${PV}.orig.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	app-portage/portage-utils
	dev-python/packaging[${PYTHON_USEDEP}]
	dev-python/pexpect[${PYTHON_USEDEP}]
	>=dev-python/python-magic-0.4.20[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	sys-apps/kmod
	sys-apps/portage
	sys-process/procps
	app-arch/xz-utils
"
BDEPEND="test? ( ${RDEPEND} )"

src_prepare() {
	# Do not run host policy detection or install distro-specific data paths
	# while building the wheel. Install the data explicitly below.
	sed -i -e '/^from sos.policies import load$/d' \
		-e '/^data_files = \[/,/^setup(/ { /^setup(/!d; }' \
		-e '/^    data_files=data_files,$/d' setup.py || die

	cp "${FILESDIR}/gentoo-policy.py" sos/policies/distros/gentoo.py || die
	cp "${FILESDIR}/portage-plugin.py" sos/report/plugins/portage.py || die
	distutils-r1_src_prepare
}

python_test() {
	PYTHONPATH="${S}" "${EPYTHON}" bin/sos --version || die
	PYTHONPATH="${S}" "${EPYTHON}" "${FILESDIR}/test-gentoo.py" || die
}

src_install() {
	distutils-r1_src_install

	doman man/en/*.1 man/en/*.5
	dodoc AUTHORS README.md
	dobashcomp completions/bash/sos

	insinto /etc/sos
	doins sos.conf
	keepdir /etc/sos/presets.d /etc/sos/groups.d /etc/sos/extras.d
	diropts -m0700
	keepdir /etc/sos/cleaner
	diropts -m0755

	insinto /usr/lib/tmpfiles.d
	newins tmpfiles/tmpfilesd-sos-rh.conf sos.conf
}
