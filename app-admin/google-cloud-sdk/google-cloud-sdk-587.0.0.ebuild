EAPI=8

DESCRIPTION="Google Cloud SDK"
HOMEPAGE="https://cloud.google.com/sdk/"
SRC_URI="
amd64? ( https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${PV}-linux-x86_64.tar.gz -> ${P}-linux-x86_64.tar.gz )
x86? ( https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${PV}-linux-x86.tar.gz -> ${P}-linux-x86.tar.gz )
arm64? ( https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-${PV}-linux-arm.tar.gz -> ${P}-linux-arm.tar.gz )
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}/google-cloud-sdk"

QA_PREBUILT="*"

src_install() {
dodir /opt/${PN}
cp -a * "${ED}/opt/${PN}/" || die "failed to install files"

dodir /usr/bin
for i in bq docker-credential-gcloud gcloud git-credential-gcloud.sh gsutil java_dev_appserver.sh; do
  dosym ../../opt/${PN}/bin/${i} /usr/bin/${i}
done
}
