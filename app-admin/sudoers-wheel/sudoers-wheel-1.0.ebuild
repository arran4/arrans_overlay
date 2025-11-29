EAPI=8

DESCRIPTION="Installs a sudoers.d drop-in to enable wheel group sudo access"
HOMEPAGE="https://www.sudo.ws/"
LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"

S="${WORKDIR}"

src_install() {
    insinto /etc/sudoers.d
    newins "${FILESDIR}"/00-wheel 00-wheel
    fperms 0440 /etc/sudoers.d/00-wheel
}
