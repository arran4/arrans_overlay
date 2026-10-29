import os
import re
import subprocess
import tempfile
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent


class RetainedWorkflowGeneratorsTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.tmp_path = Path(self.tmp.name)

    def test_kjules_generator_revision_handling_and_contents(self):
        workflow_path = REPO_ROOT / ".github/workflows/app-misc-kjules-update.yaml"
        self.assertTrue(workflow_path.exists())
        workflow_content = workflow_path.read_text()

        # Verify compgen guard against existing -rN ebuilds
        self.assertIn("compgen -G \"${ebuild_dir}/${ebuild_name}-${version}-r[0-9]*.ebuild\"", workflow_content)

        # Extract the generator snippet inside the loop
        script = f"""
set -eu
ebuild_dir="{self.tmp_path}"
ebuild_name="kjules"
version="0.0.86"
tag="v0.0.86"
description="kjules KDE application"
homepage="https://github.com/arran4/kjules"
github_owner="arran4"
github_repo="kjules"

ebuild_file="${{ebuild_dir}}/${{ebuild_name}}-${{version}}.ebuild"
if [ ! -f "$ebuild_file" ] && \\
   ! compgen -G "${{ebuild_dir}}/${{ebuild_name}}-${{version}}-r[0-9]*.ebuild" > /dev/null; then
  {{
    echo '# Copyright 2026 Gentoo Authors'
    echo '# Distributed under the terms of the GNU General Public License v2'
    echo ''
    echo '# Generated via:'
    echo '# .github/workflows/app-misc-kjules-update.yaml'
    echo 'EAPI=8'
    echo ''
    echo 'ECM_TEST="forceoptional"'
    echo 'inherit xdg ecm'
    echo ''
    echo "DESCRIPTION=\\"$description\\""
    echo "HOMEPAGE=\\"$homepage\\""
    echo 'SRC_URI="'
    echo '	https://github.com/${{github_owner}}/${{github_repo}}/archive/refs/tags/v${{PV}}.tar.gz'
    echo '		-> ${{P}}.tar.gz'
    echo '"'
    echo ''
    echo 'LICENSE="MIT"'
    echo 'SLOT="0"'
    echo 'KEYWORDS="~amd64"'
    echo 'IUSE="debug"'
    echo ''
    echo 'DEPEND="'
    echo '	dev-qt/qtbase:6[gui,network,widgets]'
    echo '	kde-frameworks/karchive:6'
    echo '	kde-frameworks/kconfig:6'
    echo '	kde-frameworks/kcoreaddons:6'
    echo '	kde-frameworks/kdbusaddons:6'
    echo '	kde-frameworks/kglobalaccel:6'
    echo '	kde-frameworks/ki18n:6'
    echo '	kde-frameworks/knotifications:6'
    echo '	kde-frameworks/kwallet:6'
    echo '	kde-frameworks/kwidgetsaddons:6'
    echo '	kde-frameworks/kwindowsystem:6'
    echo '	kde-frameworks/kxmlgui:6'
    echo '	test? ('
    echo '		kde-frameworks/kcolorscheme:6'
    echo '		kde-frameworks/kconfigwidgets:6'
    echo '		kde-frameworks/kguiaddons:6'
    echo '	)'
    echo '"'
    echo 'RDEPEND="${{DEPEND}}"'
    echo ''
    echo 'src_prepare() {{'
    echo '	ecm_src_prepare'
    echo "	sed -i -e \\"
    echo "		's/KDE_INSTALL_KXMLGUI6DIR/KDE_INSTALL_KXMLGUIDIR/g' \\"
    echo '		CMakeLists.txt || die'
    echo '	cmake_comment_add_subdirectory bench'
    echo '}}'
    echo ''
    echo 'src_configure() {{'
    echo '	ecm_src_configure'
    echo '}}'
  }} > "$ebuild_file"
fi
"""
        # First run creates kjules-0.0.86.ebuild
        subprocess.run(["bash", "-c", script], check=True)
        ebuild_file = self.tmp_path / "kjules-0.0.86.ebuild"
        self.assertTrue(ebuild_file.exists())
        content = ebuild_file.read_text()
        self.assertIn("Copyright 2026 Gentoo Authors", content)
        self.assertNotIn('S="${WORKDIR}/${P}"', content)
        self.assertIn("kde-frameworks/kwallet:6", content)
        self.assertIn("kde-frameworks/knotifications:6", content)
        self.assertIn("kde-frameworks/kdbusaddons:6", content)
        self.assertIn("kde-frameworks/kwindowsystem:6", content)
        self.assertIn('ECM_TEST="forceoptional"', content)

        # Repeated run does not modify the file
        mtime_before = ebuild_file.stat().st_mtime_ns
        subprocess.run(["bash", "-c", script], check=True)
        self.assertEqual(ebuild_file.stat().st_mtime_ns, mtime_before)

        # If bumped to -r1, it must NOT recreate 0.0.86.ebuild
        ebuild_file.unlink()
        r1_file = self.tmp_path / "kjules-0.0.86-r1.ebuild"
        r1_file.write_text(content)
        subprocess.run(["bash", "-c", script], check=True)
        self.assertFalse(ebuild_file.exists())
        self.assertTrue(r1_file.exists())

    def test_stability_matrix_generator_mv_guard_and_variables(self):
        workflow_path = REPO_ROOT / ".github/workflows/app-misc-stability-matrix-appimage-update.yaml"
        self.assertTrue(workflow_path.exists())
        workflow_content = workflow_path.read_text()

        self.assertIn("compgen -G \"${ebuild_dir}/${{ env.epn }}-${version}-r[0-9]*.ebuild\"", workflow_content)
        self.assertIn('BDEPEND="app-arch/unzip"', workflow_content)
        self.assertIn('v${PV}', workflow_content)

        # Test generation with matching names (no redundant mv)
        def run_gen(archived_name, installed_name):
            dir_path = tempfile.mkdtemp(dir=self.tmp_path)
            script = f"""
set -eu
ebuild_dir="{dir_path}"
epn="stability-matrix-appimage"
version="2.16.5"
workflow_filename="app-misc-stability-matrix-appimage-update.yaml"
description="Multi-Platform Package Manager for Stable Diffusion"
homepage="https://lykos.ai"
github_owner="LykosAI"
github_repo="StabilityMatrix"
keywords="~amd64"
StabilityMatrix_desktop_file="zone.lykos.stabilitymatrix.desktop"
StabilityMatrix_appimage_installed_name="{installed_name}"
StabilityMatrix_appimage_archived_name_amd64="{archived_name}"

ebuild_file="${{ebuild_dir}}/${{epn}}-${{version}}.ebuild"
if [ ! -f "$ebuild_file" ] && \\
   ! compgen -G "${{ebuild_dir}}/${{epn}}-${{version}}-r[0-9]*.ebuild" > /dev/null; then
  {{
    echo '# Copyright 2026 Gentoo Authors'
    echo '# Distributed under the terms of the GNU General Public License v2'
    echo ''
    echo '# Generated via:'
    echo '# .github/workflows/'"${{workflow_filename}}"
    echo 'EAPI=8'
    echo ''
    echo 'inherit desktop xdg-utils'
    echo ''
    echo "DESCRIPTION=\\"${{description}}\\""
    echo "HOMEPAGE=\\"${{homepage}}\\""
    echo 'MY_URI="https://github.com/'"${{github_owner}}/${{github_repo}}"'/releases/download/v${{PV}}"'
    echo 'SRC_URI="'
    echo '	amd64? ('
    echo '		${{MY_URI}}/StabilityMatrix-linux-x64.zip ->'
    echo '			${{P}}-StabilityMatrix-linux-x64.zip'
    echo '	)'
    echo '"'
    echo 'S="${{WORKDIR}}"'
    echo ''
    echo 'LICENSE="MIT"'
    echo 'SLOT="0"'
    echo 'KEYWORDS="'"${{keywords}}"'"'
    echo 'RESTRICT="strip"'
    echo ''
    echo 'RDEPEND="sys-libs/zlib"'
    echo 'BDEPEND="app-arch/unzip"'
    echo ''
    echo 'src_unpack() {{'
    echo '	if use amd64; then'
    echo "		unpack \\\"\\${{P}}-StabilityMatrix-linux-x64.zip\\\" \\\\"
    echo '			|| die "Cannot unpack archive file"'
    echo '	fi'
    if [ "${{StabilityMatrix_appimage_archived_name_amd64}}" != "${{StabilityMatrix_appimage_installed_name}}" ]; then
      echo '	if use amd64; then'
      echo "		mv \\\"${{StabilityMatrix_appimage_archived_name_amd64}}\\\" \\\"${{StabilityMatrix_appimage_installed_name}}\\\"  || die \\\"Cannot move archived file\\\""
      echo '	fi'
    fi
    echo "	chmod a+x \\\"${{StabilityMatrix_appimage_installed_name}}\\\" || die \\\"Cannot chmod archive file\\\""
    echo "	\\\"./${{StabilityMatrix_appimage_installed_name}}\\\" \\\\"
    echo "		--appimage-extract \\\"${{StabilityMatrix_desktop_file}}\\\" \\\\"
    echo '		|| die "Failed to extract .desktop from appimage"'
    echo "	\\\"./${{StabilityMatrix_appimage_installed_name}}\\\" --appimage-extract \\\"*.png\\\" \\\\"
    echo '		|| die "Failed to extract root icons from app image"'
    echo '}}'
  }} > "$ebuild_file"
fi
"""
            subprocess.run(["bash", "-c", script], check=True)
            return (Path(dir_path) / f"stability-matrix-appimage-2.16.5.ebuild").read_text()

        # When names match, no mv should be present
        content_same = run_gen("StabilityMatrix.AppImage", "StabilityMatrix.AppImage")
        self.assertNotIn("mv ", content_same)
        self.assertIn('BDEPEND="app-arch/unzip"', content_same)
        self.assertIn("v${PV}", content_same)

        # When names differ, mv must be present
        content_diff = run_gen("Archived.AppImage", "Installed.AppImage")
        self.assertIn('mv "Archived.AppImage" "Installed.AppImage"', content_diff)

    def test_beeper_generator_revision_awareness(self):
        workflow_path = REPO_ROOT / ".github/workflows/net-im-beeper-appimage-update.yaml"
        self.assertTrue(workflow_path.exists())
        workflow_content = workflow_path.read_text()

        self.assertIn("compgen -G \"${ebuild_dir}/${{ env.epn }}-${version}-r[0-9]*.ebuild\"", workflow_content)
        self.assertIn("Copyright 2026 Gentoo Authors", workflow_content)


if __name__ == "__main__":
    unittest.main()
