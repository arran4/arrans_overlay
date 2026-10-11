"""Offline checks for the reusable private GitHub Portage environment."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ENV_FILE = (
    Path(__file__).resolve().parents[1]
    / "app-portage/portage-gh-auth/files/github-auth.env"
)
EBUILD_FILE = ENV_FILE.parents[1] / "portage-gh-auth-1-r2.ebuild"


@unittest.skipUnless(shutil.which("git") and shutil.which("bash"), "git and bash required")
class TestPortageGhAuth(unittest.TestCase):
    def test_environment_is_valid_and_global_git_config_stays_writable(self):
        subprocess.run(["bash", "-n", str(ENV_FILE)], check=True)
        with tempfile.TemporaryDirectory() as home:
            env = os.environ.copy()
            for key in list(env):
                if key.startswith(("GIT_CONFIG_", "GH_")):
                    env.pop(key)
            env["HOME"] = home
            # Portage's package.env variables are inherited by child processes.
            command = (
                'set -a; source "$1"; set +a; '
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

    def test_ebuild_respects_lint_line_length(self):
        long_lines = [
            line_number
            for line_number, line in enumerate(EBUILD_FILE.read_text().splitlines(), 1)
            if len(line.expandtabs(8)) > 80
        ]
        self.assertEqual(long_lines, [])

    def test_installer_is_generic_and_does_not_modify_local_package_env(self):
        ebuild = EBUILD_FILE.read_text()
        config = ENV_FILE.read_text()
        self.assertIn("insinto /etc/portage/env\n", ebuild)
        self.assertIn('newins "${FILESDIR}/github-auth.env" github-auth', ebuild)
        self.assertNotIn("insinto /etc/portage/env/app-shells", ebuild)
        self.assertNotIn("package.env/", ebuild)
        self.assertNotIn("GIT_CONFIG_GLOBAL=", config)
        self.assertNotIn("FEATURES=", config)
        self.assertNotIn("SANDBOX_WRITE=", config)
        self.assertNotIn("token=", config.lower())


if __name__ == "__main__":
    unittest.main()
