# Generated via: https://github.com/arran4/arrans_overlay/blob/main/.github/workflows/dev-ml-mozilla-llm-compiler-llamafile-bin-update.yaml
EAPI=8
DESCRIPTION="LLM Compiler llm-compiler-13b-ftd is a large language model that's been trained to know how to read/write AT&T style assembly, LLVM IR, and C code. It's able to replicate the functionality of the clang compiler."
HOMEPAGE="https://huggingface.co/Mozilla/llm-compiler-13b-ftd-llamafile"
IUSE=" bf16 f16 q6_k "
SRC_URI="amd64? ( 
  bf16? ( https://huggingface.co/Mozilla/llm-compiler-13b-ftd-llamafile/resolve/main/llm-compiler-13b-ftd.BF16.llamafile?download=true -> ${P}.BF16.amd64 )
  f16? ( https://huggingface.co/Mozilla/llm-compiler-13b-ftd-llamafile/resolve/main/llm-compiler-13b-ftd.F16.llamafile?download=true -> ${P}.F16.amd64 )
  q6_k? ( https://huggingface.co/Mozilla/llm-compiler-13b-ftd-llamafile/resolve/main/llm-compiler-13b-ftd.Q6_K.llamafile?download=true -> ${P}.Q6_K.amd64 )
)"
LICENSE="Apache 2.0"
SLOT="0"
KEYWORDS="~amd64"
RDEPEND=""
DEPEND="${RDEPEND}"
S="${WORKDIR}"

src_unpack() {
    if use bf16; then
      cp "${DISTDIR}/${P}.${variant}.amd64" 'llm-compiler-13b-ftd-BF16.llamafile' || die 'failed to move llm-compiler-13b-ftd-BF16.llamafile'
      chmod +x 'llm-compiler-13b-ftd-BF16.llamafile' || die 'failed to chmod llm-compiler-13b-ftd-BF16.llamafile'
    fi
    if use f16; then
      cp "${DISTDIR}/${P}.${variant}.amd64" 'llm-compiler-13b-ftd-F16.llamafile' || die 'failed to move llm-compiler-13b-ftd-F16.llamafile'
      chmod +x 'llm-compiler-13b-ftd-F16.llamafile' || die 'failed to chmod llm-compiler-13b-ftd-F16.llamafile'
    fi
    if use q6_k; then
      cp "${DISTDIR}/${P}.${variant}.amd64" 'llm-compiler-13b-ftd-Q6_K.llamafile' || die 'failed to move llm-compiler-13b-ftd-Q6_K.llamafile'
      chmod +x 'llm-compiler-13b-ftd-Q6_K.llamafile' || die 'failed to chmod llm-compiler-13b-ftd-Q6_K.llamafile'
    fi
}

src_install() {
    exeinto /opt/bin
    if use bf16; then
      doexe "${WORKDIR}/llm-compiler-13b-ftd-BF16.llamafile"
    fi
    if use f16; then
      doexe "${WORKDIR}/llm-compiler-13b-ftd-F16.llamafile"
    fi
    if use q6_k; then
      doexe "${WORKDIR}/llm-compiler-13b-ftd-Q6_K.llamafile"
    fi
}

pkg_postinst() {
    einfo "Quick guide:"
    if use bf16; then
      doexe "${WORKDIR}/llm-compiler-13b-ftd-BF16.llamafile"
    fi
    if use f16; then
      doexe "${WORKDIR}/llm-compiler-13b-ftd-F16.llamafile"
    fi
    if use q6_k; then
      doexe "${WORKDIR}/llm-compiler-13b-ftd-Q6_K.llamafile"
    fi
}

