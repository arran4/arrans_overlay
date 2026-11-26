#!/usr/bin/env python3
"""Comprehensive test suite for which_browser automated updater."""

from __future__ import annotations

import hashlib
import http.server
import json
import os
import shutil
import subprocess
import sys
import tempfile
import threading
import unittest
from pathlib import Path
from unittest.mock import MagicMock, patch

# Ensure scripts dir is on sys.path
SCRIPTS_DIR = Path(__file__).resolve().parent
if str(SCRIPTS_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPTS_DIR))

import update_which_browser


def make_release_fixture(
    tag: str,
    asset_name: str | None = None,
    size: int = 19652142,
    sha256: str = "a9a5d22a0155d0a0ea38c5a2385d1036dd76ae5992eb8e64b5022f51f3c974ad",
    draft: bool = False,
    prerelease: bool = False,
    asset_state: str = "uploaded",
    extra_assets: list[dict] | None = None,
) -> dict:
    assets = []
    if asset_name:
        assets.append(
            {
                "name": asset_name,
                "size": size,
                "digest": f"sha256:{sha256}",
                "state": asset_state,
                "browser_download_url": f"https://github.com/arran4/which_browser/releases/download/{tag}/{asset_name}",
            }
        )
    if extra_assets:
        assets.extend(extra_assets)
    return {
        "tag_name": tag,
        "draft": draft,
        "prerelease": prerelease,
        "assets": assets,
    }


class TestWhichBrowserUpdater(unittest.TestCase):
    def setUp(self):
        self.tmpdir = tempfile.mkdtemp()
        self.work_dir = Path(self.tmpdir) / "www-misc" / "which_browser"
        self.work_dir.mkdir(parents=True)

    def tearDown(self):
        shutil.rmtree(self.tmpdir, ignore_errors=True)

    # 1. Version Precedence & Parsing
    def test_version_precedence_ordering(self):
        """Explicit version precedence must sort correctly: 0.3.0 > 0.2.22 > 0.2.6."""
        releases = [
            make_release_fixture("v0.2.6+44", "which_browser-0.2.6+44-linux.deb"),
            make_release_fixture("v0.3.0+200", "which_browser-0.3.0+200-linux.deb"),
            make_release_fixture("v0.2.22+162", "which_browser-0.2.22+162-linux.deb"),
            make_release_fixture("v0.2.22+170", "which_browser-0.2.22+170-linux.deb"),
        ]
        candidates = update_which_browser.extract_candidates(releases)
        self.assertEqual(len(candidates), 4)
        # Should be ordered highest first: v0.3.0+200, v0.2.22+170, v0.2.22+162, v0.2.6+44
        self.assertEqual(candidates[0]["tag"], "v0.3.0+200")
        self.assertEqual(candidates[1]["tag"], "v0.2.22+170")
        self.assertEqual(candidates[2]["tag"], "v0.2.22+162")
        self.assertEqual(candidates[3]["tag"], "v0.2.6+44")

    # 2. Verified fixtures: v0.2.22+162 and v0.2.6+44
    def test_verified_release_fixtures(self):
        rel_22 = make_release_fixture(
            "v0.2.22+162",
            "which_browser-0.2.22+162-linux.deb",
            size=19652142,
            sha256="a9a5d22a0155d0a0ea38c5a2385d1036dd76ae5992eb8e64b5022f51f3c974ad",
        )
        rel_6 = make_release_fixture(
            "v0.2.6+44",
            "which_browser-0.2.6+44-linux.deb",
            size=18136846,
            sha256="a949507b31396df33bc8504cdd6b8219c9e5b2975e3d3130038d9b243a95ea14",
        )
        candidates = update_which_browser.extract_candidates([rel_6, rel_22])
        self.assertEqual(len(candidates), 2)
        self.assertEqual(candidates[0]["gentoo_version"], "0.2.22.162")
        self.assertEqual(candidates[1]["gentoo_version"], "0.2.6.44")

    # 3. Invalid tag rejection
    def test_invalid_tags_rejected(self):
        invalid_tags = ["main", "v0.2.22", "v1.0.0-rc1", "invalid_tag", "latest"]
        for tag in invalid_tags:
            rel = make_release_fixture(tag, f"which_browser-{tag}-linux.deb")
            candidates = update_which_browser.extract_candidates([rel])
            self.assertEqual(candidates, [], f"Expected rejection for tag {tag}")

    # 4. Malformed filename rejection
    def test_malformed_filename_rejected(self):
        malformed = [
            "which_browser.deb",
            "which_browser-0.2.22-linux.deb",
            "which_browser-0.2.22+162.deb",
            "which_browser-0.2.22+162-windows.zip",
        ]
        for fn in malformed:
            rel = make_release_fixture("v0.2.22+162", fn)
            candidates = update_which_browser.extract_candidates([rel])
            self.assertEqual(candidates, [], f"Expected rejection for filename {fn}")

    # 5. Tag and asset mismatch rejection
    def test_tag_asset_mismatch_rejected(self):
        rel = make_release_fixture(
            "v0.2.22+162", "which_browser-0.2.21+140-linux.deb"
        )
        candidates = update_which_browser.extract_candidates([rel])
        self.assertEqual(candidates, [])

    # 6. Missing .deb asset
    def test_missing_deb_asset_rejected(self):
        rel = make_release_fixture("v0.2.22+162", None)
        candidates = update_which_browser.extract_candidates([rel])
        self.assertEqual(candidates, [])

    # 7. Duplicate/ambiguous assets
    def test_duplicate_deb_assets_rejected(self):
        extra = [
            {
                "name": "which_browser-0.2.22+162-alternative-linux.deb",
                "size": 1234,
                "state": "uploaded",
            }
        ]
        rel = make_release_fixture(
            "v0.2.22+162",
            "which_browser-0.2.22+162-linux.deb",
            extra_assets=extra,
        )
        candidates = update_which_browser.extract_candidates([rel])
        self.assertEqual(candidates, [])

    # 8. Incomplete asset upload state
    def test_incomplete_asset_state_rejected(self):
        rel = make_release_fixture(
            "v0.2.22+162",
            "which_browser-0.2.22+162-linux.deb",
            asset_state="starter",
        )
        candidates = update_which_browser.extract_candidates([rel])
        self.assertEqual(candidates, [])

    # 9. Draft and prerelease rejection
    def test_draft_and_prerelease_skipped(self):
        draft_rel = make_release_fixture(
            "v0.2.23+163", "which_browser-0.2.23+163-linux.deb", draft=True
        )
        pre_rel = make_release_fixture(
            "v0.2.24+164", "which_browser-0.2.24+164-linux.deb", prerelease=True
        )
        candidates = update_which_browser.extract_candidates([draft_rel, pre_rel])
        self.assertEqual(candidates, [])

    # 10. HTTP 404 download validation failure
    @patch("urllib.request.urlopen")
    def test_verify_download_http_404(self, mock_urlopen):
        import urllib.error
        mock_urlopen.side_effect = urllib.error.HTTPError(
            "http://example.com", 404, "Not Found", {}, None
        )
        ok, reason = update_which_browser.verify_download("http://example.com/deb")
        self.assertFalse(ok)
        self.assertIn("404", reason)

    # 11. HTTP 200 containing HTML error page rejection
    @patch("urllib.request.urlopen")
    def test_verify_download_html_content_rejected(self, mock_urlopen):
        # Case A: Content-Type header is text/html
        mock_resp_a = MagicMock()
        mock_resp_a.status = 200
        mock_resp_a.headers = {"Content-Type": "text/html; charset=utf-8"}
        mock_resp_a.__enter__.return_value = mock_resp_a
        mock_urlopen.return_value = mock_resp_a

        ok, reason = update_which_browser.verify_download("http://example.com/deb")
        self.assertFalse(ok)
        self.assertIn("Invalid Content-Type", reason)

        # Case B: Content-Type is generic stream, but body is HTML
        mock_resp_b = MagicMock()
        mock_resp_b.status = 200
        mock_resp_b.headers = {"Content-Type": "application/octet-stream"}
        mock_resp_b.read.side_effect = [b"<!DOCTYPE html><html>Error</html>", b""]
        mock_resp_b.__enter__.return_value = mock_resp_b
        mock_urlopen.return_value = mock_resp_b

        ok, reason = update_which_browser.verify_download("http://example.com/deb")
        self.assertFalse(ok)
        self.assertIn("HTML page", reason)

    # 12. Size mismatch rejection
    @patch("urllib.request.urlopen")
    def test_verify_download_size_mismatch(self, mock_urlopen):
        mock_resp = MagicMock()
        mock_resp.status = 200
        mock_resp.headers = {"Content-Type": "application/octet-stream"}
        mock_resp.read.side_effect = [b"1234567890", b""]
        mock_resp.__enter__.return_value = mock_resp
        mock_urlopen.return_value = mock_resp

        ok, reason = update_which_browser.verify_download(
            "http://example.com/deb", expected_size=20
        )
        self.assertFalse(ok)
        self.assertIn("Size mismatch", reason)

    # 13. Checksum mismatch rejection
    @patch("urllib.request.urlopen")
    def test_verify_download_checksum_mismatch(self, mock_urlopen):
        payload = b"valid binary content"
        mock_resp = MagicMock()
        mock_resp.status = 200
        mock_resp.headers = {"Content-Type": "application/octet-stream"}
        mock_resp.read.side_effect = [payload, b""]
        mock_resp.__enter__.return_value = mock_resp
        mock_urlopen.return_value = mock_resp

        ok, reason = update_which_browser.verify_download(
            "http://example.com/deb",
            expected_size=len(payload),
            expected_sha256="0000000000000000000000000000000000000000000000000000000000000000",
        )
        self.assertFalse(ok)
        self.assertIn("SHA-256 mismatch", reason)

    # 14. Existing ebuild detection (no-op)
    def test_existing_ebuild_detection(self):
        (self.work_dir / "which_browser-0.2.22.162.ebuild").touch()
        self.assertTrue(
            update_which_browser.check_ebuild_exists(self.work_dir, "0.2.22.162")
        )
        self.assertFalse(
            update_which_browser.check_ebuild_exists(self.work_dir, "0.2.22.163")
        )

    # 15. Existing open PR detection (no-op)
    @patch("update_which_browser.run_cmd")
    @patch("shutil.which")
    def test_existing_pr_detection(self, mock_which, mock_run_cmd):
        mock_which.return_value = "/usr/bin/gh"
        mock_res = MagicMock()
        mock_res.stdout = '[{"number": 999, "url": "https://github.com/..."}]'
        mock_run_cmd.return_value = mock_res

        self.assertTrue(
            update_which_browser.check_pr_exists("v0.2.22+162", "0.2.22.162")
        )

    # 16. Ebuild content generation: lines under 80 chars, EAPI 8, static SRC_URI
    def test_generate_ebuild_content(self):
        target_url = "https://which-browser-site.pages.dev/downloads/v0.2.22/which_browser-0.2.22+162-linux.deb"
        content = update_which_browser.generate_ebuild_content(
            base_version="0.2.22",
            archive_name="which_browser-0.2.22+162-linux.deb",
            target_url=target_url,
        )
        self.assertIn("EAPI=8", content)
        self.assertIn(target_url, content)
        self.assertIn('unpack_deb "which_browser-0.2.22+162-linux.deb"', content)
        self.assertIn("dosym ../share/which_browser/which_browser", content)
        self.assertNotIn('die "Unexpected PV format', content)
        self.assertNotIn("RESTRICT=\"fetch\"", content)

        # Verify no lines exceed 80 positions (except lines containing URLs)
        for i, line in enumerate(content.splitlines(), start=1):
            if "https://" in line or "http://" in line:
                continue
            line_len = len(line.expandtabs(4))
            self.assertLessEqual(
                line_len,
                80,
                f"Line {i} exceeds 80 characters ({line_len}): {line}",
            )

    # 17. Transactional generation and rollback on g2 failure
    @patch("update_which_browser.run_cmd")
    def test_transactional_generation_rollback(self, mock_run_cmd):
        candidate = {
            "tag": "v0.2.22+162",
            "base_version": "0.2.22",
            "build_suffix": "162",
            "gentoo_version": "0.2.22.162",
            "filename": "which_browser-0.2.22+162-linux.deb",
        }
        manifest_path = self.work_dir / "Manifest"
        original_manifest_content = "DIST original-dist.deb 100 SHA512 abc\n"
        manifest_path.write_text(original_manifest_content)

        # Simulate g2 manifest upsert failure
        mock_run_cmd.side_effect = subprocess.CalledProcessError(1, ["g2"])

        with self.assertRaises(subprocess.CalledProcessError):
            update_which_browser.apply_update(
                work_dir=self.work_dir,
                candidate=candidate,
                target_url="https://example.com/deb",
            )

        # Ensure ebuild was deleted (rolled back)
        ebuild_path = self.work_dir / "which_browser-0.2.22.162.ebuild"
        self.assertFalse(ebuild_path.exists())

        # Ensure original Manifest was restored
        self.assertEqual(manifest_path.read_text(), original_manifest_content)
        self.assertFalse((self.work_dir / "Manifest.bak").exists())

    # 18. End-to-end simulated run with local mock HTTP server
    def test_end_to_end_successful_update(self):
        payload = b"mock debian binary archive payload 12345"
        payload_sha256 = hashlib.sha256(payload).hexdigest()

        # Simple HTTP handler to serve payload
        class MockServerHandler(http.server.BaseHTTPRequestHandler):
            def do_GET(self):
                if self.path == "/downloads/v0.2.22/which_browser-0.2.22+162-linux.deb":
                    self.send_response(200)
                    self.send_header("Content-Type", "application/octet-stream")
                    self.send_header("Content-Length", str(len(payload)))
                    self.end_headers()
                    self.wfile.write(payload)
                else:
                    self.send_response(404)
                    self.end_headers()

            def log_message(self, format, *args):
                pass

        server = http.server.HTTPServer(("127.0.0.1", 0), MockServerHandler)
        port = server.server_port
        thread = threading.Thread(target=server.serve_forever)
        thread.daemon = True
        thread.start()

        base_url = f"http://127.0.0.1:{port}/downloads"

        mock_releases = [
            make_release_fixture(
                "v0.2.22+162",
                "which_browser-0.2.22+162-linux.deb",
                size=len(payload),
                sha256=payload_sha256,
            )
        ]

        try:
            with patch("update_which_browser.get_github_releases", return_value=mock_releases), \
                 patch("update_which_browser.check_pr_exists", return_value=False), \
                 patch("update_which_browser.run_cmd") as mock_run_cmd:

                # Fake g2 manifest execution to append to Manifest
                def fake_g2(cmd, **kwargs):
                    manifest_file = Path(cmd[5])
                    with open(manifest_file, "a") as f:
                        f.write(f"DIST which_browser-0.2.22+162-linux.deb {len(payload)} SHA512 deadbeef\n")
                    res = MagicMock()
                    res.returncode = 0
                    return res

                mock_run_cmd.side_effect = fake_g2

                exit_code = update_which_browser.main(
                    [
                        "--work-dir", str(self.work_dir),
                        "--base-download-url", base_url,
                    ]
                )
                self.assertEqual(exit_code, 0)

                # Verify ebuild and Manifest exist
                ebuild_path = self.work_dir / "which_browser-0.2.22.162.ebuild"
                self.assertTrue(ebuild_path.exists())
                manifest_path = self.work_dir / "Manifest"
                self.assertTrue(manifest_path.exists())
                self.assertIn("which_browser-0.2.22+162-linux.deb", manifest_path.read_text())

                # Idempotency / Rerun test: Second run must detect existing ebuild and exit 0 (no-op)
                exit_code_rerun = update_which_browser.main(
                    [
                        "--work-dir", str(self.work_dir),
                        "--base-download-url", base_url,
                    ]
                )
                self.assertEqual(exit_code_rerun, 0)
        finally:
            server.shutdown()
            server.server_close()


if __name__ == "__main__":
    unittest.main()
