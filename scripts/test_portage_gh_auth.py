"""Offline checks for the package-specific GitHub authentication environment."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ENV_FILE = (
    Path(__file__).resolve().parents[1]
    / "app-portage/portage-gh-auth/files/a4sh.env"
)
EBUILD_FILE = ENV_FILE.parents[1] / "portage-gh-auth-1.ebuild"


@unittest.skipUnless(shutil.which("git") and shutil.which("bash"), "git and bash required")
class TestPortageGhAuth(unittest.TestCase):
    def test_environment_is_valid_and_only_scopes_github(self):
        subprocess.run(["bash", "-n", str(ENV_FILE)], check=True)
        with tempfile.TemporaryDirectory() as home:
            env = os.environ.copy()
            for key in list(env):
                if key.startswith("GIT_CONFIG_") or key.startswith("GH_"):
                    env.pop(key)
            env["HOME"] = home
            # A package-specific bashrc must export values for child git processes.
            command = (
                'source "$1"; '
                'git config --get credential.https://github.com.helper; '
                'git config --global --add safe.directory "$2"; '
                'git config --global --get-all safe.directory'
            )
            result = subprocess.run(
                ["bash", "-c", command, "bash", str(ENV_FILE), "/tmp/portage-checkout"],
                capture_output=True,
                text=True,
                env=env,
                check=True,
            )
            self.assertEqual(
                result.stdout.splitlines(),
                ["!gh auth git-credential", "/tmp/portage-checkout"],
            )
            self.assertTrue((Path(home) / ".gitconfig").exists())

    def test_installer_uses_auto_per_package_env_without_global_override(self):
        ebuild = EBUILD_FILE.read_text()
        config = ENV_FILE.read_text()
        self.assertIn("insinto /etc/portage/env/app-shells", ebuild)
        self.assertIn('newins "${FILESDIR}/a4sh.env" a4sh', ebuild)
        self.assertNotIn("GIT_CONFIG_GLOBAL=", config)
        self.assertNotIn("FEATURES=", config)
        self.assertNotIn("SANDBOX_WRITE=", config)
        self.assertNotIn("token=", config.lower())


if __name__ == "__main__":
    unittest.main()
