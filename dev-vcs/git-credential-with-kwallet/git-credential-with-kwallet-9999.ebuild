# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="A git credential helper that stores credentials in the KDE wallet"
HOMEPAGE="https://github.com/epwr/git-credential-with-kwallet"
EGIT_REPO_URI="https://github.com/epwr/git-credential-with-kwallet.git"

LICENSE="MIT"
SLOT="0"

RDEPEND="
	dev-lang/ruby
	dev-qt/qttools[dbus]
	dev-vcs/git
	kde-frameworks/kwallet
"

src_install() {
	dobin git-credential-with-kwallet
	einstalldocs
}
