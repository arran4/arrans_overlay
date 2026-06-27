EAPI=8

PYTHON_COMPAT=( python3_{10..12} )
inherit git-r3 python-single-r1

DESCRIPTION="Tool to build KDE software from source"
HOMEPAGE="https://kde-builder.kde.org/"
EGIT_REPO_URI="https://invent.kde.org/sdk/kde-builder.git"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS=""
IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/setproctitle[${PYTHON_USEDEP}]
	')
"

src_install() {
	insinto /usr/share/${PN}/kde_builder_lib
	doins -r kde_builder_lib/*

	insinto /usr/share/${PN}/data
	doins -r data/*

	exeinto /usr/share/${PN}
	doexe kde-builder

	python_fix_shebang "${ED}/usr/share/${PN}/kde-builder"

	dosym -r /usr/share/${PN}/kde-builder /usr/bin/kde-builder

	einstalldocs
}
