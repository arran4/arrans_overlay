EAPI=8

DESCRIPTION="Installs a sudoers.d drop-in to enable dispatch-conf without password"
HOMEPAGE="https://www.sudo.ws/"
LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"

S="${WORKDIR}"

src_install() {
    insinto /etc/sudoers.d
    newins "${FILESDIR}"/10-dispatch-conf 10-dispatch-conf
    fperms 0440 /etc/sudoers.d/10-dispatch-conf
}
