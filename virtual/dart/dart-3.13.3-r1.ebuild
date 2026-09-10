# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Virtual for the Dart SDK"

SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~riscv"

RDEPEND="|| (
	~dev-lang/dart-3.13.3
	~dev-lang/dart-bin-3.13.3
)"
