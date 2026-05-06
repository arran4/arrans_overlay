# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/app-misc-voxtype-bin-update.yaml
EAPI=8
DESCRIPTION="Push-to-talk voice-to-text for Linux. Optimized for Wayland, works on X11 too."
HOMEPAGE="https://voxtype.io/"
SRC_URI="
	amd64? (
		!onnx? (
			!cpu_flags_x86_avx512? ( !vulkan? ( https://github.com/peteonrails/voxtype/releases/download/v${PV}/voxtype-${PV}-linux-x86_64-avx2 -> ${P}-voxtype-${PV}-linux-x86_64-avx2 ) )
			cpu_flags_x86_avx512? ( https://github.com/peteonrails/voxtype/releases/download/v${PV}/voxtype-${PV}-linux-x86_64-avx512 -> ${P}-voxtype-${PV}-linux-x86_64-avx512 )
			vulkan? ( https://github.com/peteonrails/voxtype/releases/download/v${PV}/voxtype-${PV}-linux-x86_64-vulkan -> ${P}-voxtype-${PV}-linux-x86_64-vulkan )
		)
		onnx? (
			!cpu_flags_x86_avx512? ( !cuda? ( !rocm? ( https://github.com/peteonrails/voxtype/releases/download/v${PV}/voxtype-${PV}-linux-x86_64-onnx-avx2 -> ${P}-voxtype-${PV}-linux-x86_64-onnx-avx2 ) ) )
			cpu_flags_x86_avx512? ( https://github.com/peteonrails/voxtype/releases/download/v${PV}/voxtype-${PV}-linux-x86_64-onnx-avx512 -> ${P}-voxtype-${PV}-linux-x86_64-onnx-avx512 )
			cuda? ( https://github.com/peteonrails/voxtype/releases/download/v${PV}/voxtype-${PV}-linux-x86_64-onnx-cuda -> ${P}-voxtype-${PV}-linux-x86_64-onnx-cuda )
			rocm? ( https://github.com/peteonrails/voxtype/releases/download/v${PV}/voxtype-${PV}-linux-x86_64-onnx-rocm -> ${P}-voxtype-${PV}-linux-x86_64-onnx-rocm )
		)
	)
"
LICENSE="MIT"
SLOT="0"
RESTRICT="strip"
QA_PREBUILT="usr/bin/voxtype"
KEYWORDS="~amd64"
IUSE="cpu_flags_x86_avx512 vulkan cuda rocm onnx""

REQUIRED_USE="?? ( cpu_flags_x86_avx512 vulkan cuda rocm )""

RDEPEND="gui-libs/wl-clipboard app-accessibility/ydotool x11-misc/dotool"

S="${WORKDIR}"

src_unpack() {
	if use amd64; then
		local target="avx2"
		use cpu_flags_x86_avx512 && target="avx512"
		use vulkan && target="vulkan"
		use onnx && target="onnx-avx2"
		use onnx && use cpu_flags_x86_avx512 && target="onnx-avx512"
		use onnx && use cuda && target="onnx-cuda"
		use onnx && use rocm && target="onnx-rocm"
		cp "${DISTDIR}/${P}-voxtype-${PV}-linux-x86_64-${target}" "${S}/voxtype" || die
	fi
}

src_install() {
	exeinto /usr/bin
	if use amd64; then
		newexe "${S}/voxtype" voxtype || die
	fi
}
