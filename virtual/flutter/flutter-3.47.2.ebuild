# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Virtual for the Flutter SDK"

SLOT="0"
KEYWORDS="~amd64"

RDEPEND="|| (
	~dev-lang/flutter-3.47.2
	~dev-lang/flutter-bin-3.47.2
)"
