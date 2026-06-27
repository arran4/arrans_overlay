EAPI=8

DISTUTILS_USE_PEP517=poetry
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{10..12} )

inherit distutils-r1 git-r3

DESCRIPTION="Tool to build KDE software from source"
HOMEPAGE="https://kde-builder.kde.org/"
EGIT_REPO_URI="https://invent.kde.org/sdk/kde-builder.git"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS=""

RDEPEND="
	$(python_gen_cond_dep '
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/setproctitle[${PYTHON_USEDEP}]
	')
"

src_install() {
	distutils-r1_src_install

	insinto /usr/share/${PN}
	doins -r data
}
