# Copyright 2025 Gentoo Authors
# Distributed under the terms of the MIT License

EAPI=8

EGO_SUM=(
	"github.com/arran4/go-subcommand v0.0.12"
	"github.com/teekennedy/goldmark-markdown v0.5.1"
	"github.com/yuin/goldmark v1.7.8"
	"golang.org/x/mod v0.31.0"
	"golang.org/x/text v0.32.0"
)

inherit go-module

DESCRIPTION="Splits markdown files into chunks suitable for processing with other tools"
HOMEPAGE="https://github.com/arran4/mdsplit"

SRC_URI="https://github.com/arran4/mdsplit/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND="app-arch/unzip"
RDEPEND="!app-text/mdsplit-bin"
