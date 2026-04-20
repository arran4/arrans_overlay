EAPI=8

DESCRIPTION="Installs a sudoers.d drop-in to enable emerge without password"
HOMEPAGE="https://www.sudo.ws/"
LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"

RDEPEND="app-admin/sudo"

S="${WORKDIR}"

src_install() {
    insinto /etc/sudoers.d
    doins "${FILESDIR}"/00-emerge
    fperms 0440 /etc/sudoers.d/00-emerge
}
