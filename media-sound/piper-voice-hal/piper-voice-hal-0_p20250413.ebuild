# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="HAL 9000 voice model for Piper TTS"
HOMEPAGE="https://huggingface.co/campwill/HAL-9000-Piper-TTS"
COMMIT="5ad905a1f42cb33364df9d3856491bca8738b9fa"
SRC_URI="
	https://huggingface.co/campwill/HAL-9000-Piper-TTS/resolve/${COMMIT}/hal.onnx?download=1 -> ${PN}-${PV}.onnx
	https://huggingface.co/campwill/HAL-9000-Piper-TTS/resolve/${COMMIT}/hal.onnx.json?download=1 -> ${PN}-${PV}.onnx.json
	https://huggingface.co/campwill/HAL-9000-Piper-TTS/resolve/${COMMIT}/model_sample.wav?download=1 -> ${PN}-${PV}.wav
	https://huggingface.co/campwill/HAL-9000-Piper-TTS/resolve/${COMMIT}/README.md?download=1 -> ${PN}-${PV}.README.md
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror strip test"

S="${WORKDIR}"

RDEPEND="media-sound/piper"

src_install() {
local voicedir="/usr/share/piper/voices/hal-9000"

insinto "${voicedir}"
newins "${DISTDIR}/${PN}-${PV}.onnx" hal-9000.onnx || die
newins "${DISTDIR}/${PN}-${PV}.onnx.json" hal-9000.onnx.json || die
newins "${DISTDIR}/${PN}-${PV}.wav" model_sample.wav || die

dodoc "${DISTDIR}/${PN}-${PV}.README.md"
}
