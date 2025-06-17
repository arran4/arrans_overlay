# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-admin-ejson-bin-update.yaml
EAPI=8
DESCRIPTION="EJSON is a small library to manage encrypted secrets using asymmetric encryption."
HOMEPAGE="https://github.com/Shopify/ejson"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=" doc"
REQUIRED_USE=""
DEPEND=""
RDEPEND=""
S="${WORKDIR}"


SRC_URI="
  amd64? (  https://github.com/Shopify/ejson/releases/download/v1.5.4/ejson_${PV}_linux_amd64.tar.gz -> ${P}-ejson_${PV}_linux_amd64.tar.gz  )  
  arm64? (  https://github.com/Shopify/ejson/releases/download/v1.5.4/ejson_${PV}_linux_arm64.tar.gz -> ${P}-ejson_${PV}_linux_arm64.tar.gz  )  
"

src_unpack() {
  if use amd64; then
    unpack "${DISTDIR}/${P}-ejson_${PV}_linux_amd64.tar.gz" || die "Can't unpack archive file"
  fi
  if use arm64; then
    unpack "${DISTDIR}/${P}-ejson_${PV}_linux_arm64.tar.gz" || die "Can't unpack archive file"
  fi
}

src_install() {
  exeinto /opt/bin
  if use amd64; then
    newexe "ejson" "ejson" || die "Failed to install Binary"
  fi
  if use arm64; then
    newexe "ejson" "ejson" || die "Failed to install Binary"
  fi
  if use doc; then
    newdoc "CHANGELOG.md" "CHANGELOG.md" || die "Failed to install document CHANGELOG.md"
    newdoc "LICENSE.txt" "LICENSE.txt" || die "Failed to install document LICENSE.txt"
    newdoc "README.md" "README.md" || die "Failed to install document README.md"
  fi
}

