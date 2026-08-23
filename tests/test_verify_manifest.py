import os
import sys
import unittest

# Ensure scripts directory is in sys.path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'scripts'))
from verify_manifest import parse_ebuild_variables, resolve_variables, extract_uris

class TestVerifyManifest(unittest.TestCase):

    def test_parse_variables_unrevised(self):
        vars_dict = parse_ebuild_variables("foo-1.2.3.ebuild")
        self.assertIsNotNone(vars_dict)
        self.assertEqual(vars_dict['PN'], 'foo')
        self.assertEqual(vars_dict['PV'], '1.2.3')
        self.assertEqual(vars_dict['P'], 'foo-1.2.3')
        self.assertEqual(vars_dict['PR'], 'r0')
        self.assertEqual(vars_dict['PVR'], '1.2.3')
        self.assertEqual(vars_dict['PF'], 'foo-1.2.3')

    def test_parse_variables_revised_r1(self):
        vars_dict = parse_ebuild_variables("foo-1.2.3-r1.ebuild")
        self.assertIsNotNone(vars_dict)
        self.assertEqual(vars_dict['PN'], 'foo')
        self.assertEqual(vars_dict['PV'], '1.2.3')
        self.assertEqual(vars_dict['P'], 'foo-1.2.3')
        self.assertEqual(vars_dict['PR'], 'r1')
        self.assertEqual(vars_dict['PVR'], '1.2.3-r1')
        self.assertEqual(vars_dict['PF'], 'foo-1.2.3-r1')

    def test_parse_variables_hyphenated_revised_r12(self):
        vars_dict = parse_ebuild_variables("foo-bar-1.2.3-r12.ebuild")
        self.assertIsNotNone(vars_dict)
        self.assertEqual(vars_dict['PN'], 'foo-bar')
        self.assertEqual(vars_dict['PV'], '1.2.3')
        self.assertEqual(vars_dict['P'], 'foo-bar-1.2.3')
        self.assertEqual(vars_dict['PR'], 'r12')
        self.assertEqual(vars_dict['PVR'], '1.2.3-r12')
        self.assertEqual(vars_dict['PF'], 'foo-bar-1.2.3-r12')

    def test_parse_variables_suffixes(self):
        vars_alpha = parse_ebuild_variables("foo-1.2.3_alpha1-r2.ebuild")
        self.assertEqual(vars_alpha['PN'], 'foo')
        self.assertEqual(vars_alpha['PV'], '1.2.3_alpha1')
        self.assertEqual(vars_alpha['P'], 'foo-1.2.3_alpha1')
        self.assertEqual(vars_alpha['PR'], 'r2')
        self.assertEqual(vars_alpha['PVR'], '1.2.3_alpha1-r2')
        self.assertEqual(vars_alpha['PF'], 'foo-1.2.3_alpha1-r2')

        vars_patch = parse_ebuild_variables("foo-1.2.3_p20260101-r1.ebuild")
        self.assertEqual(vars_patch['PN'], 'foo')
        self.assertEqual(vars_patch['PV'], '1.2.3_p20260101')
        self.assertEqual(vars_patch['P'], 'foo-1.2.3_p20260101')
        self.assertEqual(vars_patch['PR'], 'r1')
        self.assertEqual(vars_patch['PVR'], '1.2.3_p20260101-r1')
        self.assertEqual(vars_patch['PF'], 'foo-1.2.3_p20260101-r1')

        vars_rc = parse_ebuild_variables("foo-1.0_rc2.ebuild")
        self.assertEqual(vars_rc['PN'], 'foo')
        self.assertEqual(vars_rc['PV'], '1.0_rc2')
        self.assertEqual(vars_rc['P'], 'foo-1.0_rc2')
        self.assertEqual(vars_rc['PR'], 'r0')
        self.assertEqual(vars_rc['PVR'], '1.0_rc2')
        self.assertEqual(vars_rc['PF'], 'foo-1.0_rc2')

    def test_parse_variables_with_content_assignments(self):
        content = """
COMMIT="e337a5f69a9bea30e58d05bd40184d79cc099628"
MY_VAR='custom_value'
"""
        vars_dict = parse_ebuild_variables("rubik-1.0-r1.ebuild", content)
        self.assertIsNotNone(vars_dict)
        self.assertEqual(vars_dict['PN'], 'rubik')
        self.assertEqual(vars_dict['PV'], '1.0')
        self.assertEqual(vars_dict['P'], 'rubik-1.0')
        self.assertEqual(vars_dict['PR'], 'r1')
        self.assertEqual(vars_dict['PVR'], '1.0-r1')
        self.assertEqual(vars_dict['PF'], 'rubik-1.0-r1')
        self.assertEqual(vars_dict['COMMIT'], 'e337a5f69a9bea30e58d05bd40184d79cc099628')
        self.assertEqual(vars_dict['MY_VAR'], 'custom_value')

    def test_src_uri_regression_revision_independent_naming(self):
        # When an ebuild is revised (e.g. rubik-1.0-r1.ebuild or foo-1.0-r1.ebuild),
        # SRC_URI using ${P} or ${PN}-${PV} MUST resolve to the base version (1.0),
        # not the revision version (1.0-r1).
        content = 'SRC_URI="https://github.com/example/foo/archive/v${PV}.tar.gz -> ${P}.tar.gz"'
        vars_dict = parse_ebuild_variables("foo-1.2.3-r1.ebuild", content)
        uris = extract_uris(content, vars_dict)
        self.assertEqual(uris, [("https://github.com/example/foo/archive/v1.2.3.tar.gz", "foo-1.2.3.tar.gz")])

        # Test ${PN}-${PV}
        content_pnpv = 'SRC_URI="https://github.com/googlefonts/rubik/archive/${COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"'
        vars_rubik = parse_ebuild_variables("rubik-1.0-r1.ebuild", 'COMMIT="abc1234"\n' + content_pnpv)
        uris_rubik = extract_uris(content_pnpv, vars_rubik)
        self.assertEqual(uris_rubik, [("https://github.com/googlefonts/rubik/archive/abc1234.tar.gz", "rubik-1.0.tar.gz")])

    def test_src_uri_regression_revision_dependent_naming(self):
        # When an ebuild explicitly uses ${PVR} or ${PF}, it should include the revision
        content_pf = 'SRC_URI="https://example.com/download/${PF}.tar.gz"'
        vars_dict = parse_ebuild_variables("foo-1.2.3-r1.ebuild", content_pf)
        uris_pf = extract_uris(content_pf, vars_dict)
        self.assertEqual(uris_pf, [("https://example.com/download/foo-1.2.3-r1.tar.gz", "foo-1.2.3-r1.tar.gz")])

        content_pvr = 'SRC_URI="https://example.com/download/${PN}-${PVR}.tar.gz"'
        uris_pvr = extract_uris(content_pvr, vars_dict)
        self.assertEqual(uris_pvr, [("https://example.com/download/foo-1.2.3-r1.tar.gz", "foo-1.2.3-r1.tar.gz")])

    def test_caelestia_shell_uris(self):
        content = """
M3SHAPES_REV="bdc327b29f95394a732baf3c9b19658ba23755b6"
SRC_URI="
	https://github.com/caelestia-dots/shell/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz
	https://github.com/soramanew/m3shapes/archive/${M3SHAPES_REV}.tar.gz -> caelestia-m3shapes-${M3SHAPES_REV}.tar.gz
"
"""
        vars_shell = parse_ebuild_variables("caelestia-shell-2.2.0-r1.ebuild", content)
        uris = extract_uris(content, vars_shell)
        expected = [
            ("https://github.com/caelestia-dots/shell/archive/refs/tags/v2.2.0.tar.gz", "caelestia-shell-2.2.0.tar.gz"),
            ("https://github.com/soramanew/m3shapes/archive/bdc327b29f95394a732baf3c9b19658ba23755b6.tar.gz", "caelestia-m3shapes-bdc327b29f95394a732baf3c9b19658ba23755b6.tar.gz")
        ]
        self.assertEqual(uris, expected)

    def test_caelestia_cli_uris(self):
        content = """
SRC_URI="https://github.com/caelestia-dots/cli/archive/refs/tags/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
"""
        vars_cli = parse_ebuild_variables("caelestia-cli-1.1.2.ebuild", content)
        uris = extract_uris(content, vars_cli)
        expected = [
            ("https://github.com/caelestia-dots/cli/archive/refs/tags/v1.1.2.tar.gz", "caelestia-cli-1.1.2.tar.gz")
        ]
        self.assertEqual(uris, expected)

    def test_material_symbols_variable_uris(self):
        content = """
MDI_COMMIT="481507587f1bdfe712939398c4dc0ecc2079ea7c"
MDI_BASE="https://raw.githubusercontent.com/google/material-design-icons/${MDI_COMMIT}/variablefont"

SRC_URI="
	${MDI_BASE}/MaterialSymbolsOutlined%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf
		-> MaterialSymbolsOutlined-${PV}.ttf
	${MDI_BASE}/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf
		-> MaterialSymbolsRounded-${PV}.ttf
	${MDI_BASE}/MaterialSymbolsSharp%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf
		-> MaterialSymbolsSharp-${PV}.ttf
"
"""
        vars_mdi = parse_ebuild_variables("material-symbols-variable-0_p20260724.ebuild", content)
        uris = extract_uris(content, vars_mdi)
        expected = [
            ("https://raw.githubusercontent.com/google/material-design-icons/481507587f1bdfe712939398c4dc0ecc2079ea7c/variablefont/MaterialSymbolsOutlined%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf", "MaterialSymbolsOutlined-0_p20260724.ttf"),
            ("https://raw.githubusercontent.com/google/material-design-icons/481507587f1bdfe712939398c4dc0ecc2079ea7c/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf", "MaterialSymbolsRounded-0_p20260724.ttf"),
            ("https://raw.githubusercontent.com/google/material-design-icons/481507587f1bdfe712939398c4dc0ecc2079ea7c/variablefont/MaterialSymbolsSharp%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf", "MaterialSymbolsSharp-0_p20260724.ttf"),
        ]
    def test_actual_overlay_manifests(self):
        root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
        pkgs = [
            "gui-apps/caelestia-cli",
            "gui-apps/caelestia-shell",
            "media-fonts/rubik",
            "media-fonts/material-symbols-variable",
        ]
        for rel_pkg in pkgs:
            pkg_path = os.path.join(root_dir, rel_pkg)
            if not os.path.isdir(pkg_path):
                continue
            manifest_path = os.path.join(pkg_path, 'Manifest')
            self.assertTrue(os.path.isfile(manifest_path))
            with open(manifest_path, 'r') as f:
                manifest_dists = {line.split()[1] for line in f if line.startswith("DIST ")}

            extracted_dists = set()
            ebuilds = [f for f in os.listdir(pkg_path) if f.endswith('.ebuild')]
            for eb in ebuilds:
                eb_path = os.path.join(pkg_path, eb)
                with open(eb_path, 'r') as f:
                    content = f.read()
                vars_dict = parse_ebuild_variables(eb, content)
                self.assertIsNotNone(vars_dict)
                uris = extract_uris(content, vars_dict)
                for _, filename in uris:
                    extracted_dists.add(filename)

            self.assertEqual(manifest_dists, extracted_dists, f"Mismatch in {rel_pkg}")

if __name__ == '__main__':
    unittest.main()
