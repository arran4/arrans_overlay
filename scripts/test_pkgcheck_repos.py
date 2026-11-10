import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from pkgcheck_repos import (
    Repository,
    docker_command,
    parse_repositories,
    read_masters,
    validate_masters,
    write_portage_config,
)


class PkgcheckReposTest(unittest.TestCase):
    def test_full_line_and_end_of_line_comments(self):
        repos = parse_repositories(
            "# Full line\n  # Indented full line\n\n"
            "gentoo https://example.org/gentoo.git # trailing comment\r\n"
            "guru https://example.org/guru.git\n"
            "hyproverlay https://example.org/hyproverlay.git   # with spaces\n"
        )
        self.assertEqual([repo.name for repo in repos], ["gentoo", "guru", "hyproverlay"])
        self.assertEqual(repos[0].url, "https://example.org/gentoo.git")

    def test_invalid_entries_fail_closed(self):
        cases = (
            "repo",
            "repo https://example.org/repo.git extra",
            "../repo https://example.org/repo.git",
            "repo git@example.org:repo.git",
            "repo http://example.org/repo.git",
            "repo https://user:token@example.org/repo.git",
            "repo https://example.org/repo.git\nrepo https://example.org/another.git",
            "# no repositories\n",
        )
        for case in cases:
            with self.subTest(case=case), self.assertRaises(ValueError):
                parse_repositories(case)

    def test_masters_must_be_listed(self):
        repos = [Repository("gentoo", "https://example.org/gentoo.git")]
        self.assertEqual(read_masters("masters = gentoo guru # commented\n"), ["gentoo", "guru"])
        with self.assertRaisesRegex(ValueError, "guru"):
            validate_masters(repos, ["gentoo", "guru"])
        validate_masters(repos, ["gentoo"])
        with self.assertRaisesRegex(ValueError, "gentoo required"):
            validate_masters([Repository("guru", "https://example.org/guru.git")], ["guru"])

    def test_portage_configs_and_mounts_come_from_same_list(self):
        repos = [
            Repository("gentoo", "https://example.org/gentoo.git"),
            Repository("guru", "https://example.org/guru.git"),
            Repository("hyproverlay", "https://example.org/hyproverlay.git"),
        ]
        with tempfile.TemporaryDirectory() as directory:
            config_dir = Path(directory)
            write_portage_config(config_dir, repos, [repo.name for repo in repos])
            self.assertEqual(
                (config_dir / "arrans-overlay.conf").read_text(),
                "[arrans-overlay]\nlocation = /var/db/repos/arrans-overlay\n"
                "masters = gentoo guru hyproverlay\nauto-sync = no\n",
            )
            self.assertIn("location = /var/db/repos/guru", (config_dir / "guru.conf").read_text())
            command = docker_command(Path("/workspace"), config_dir, repos)
            for name in ("gentoo", "guru", "hyproverlay"):
                self.assertIn(f"/workspace/repos/{name}:/var/db/repos/{name}:ro", command)
            self.assertIn(f"{config_dir}:/etc/portage/repos.conf:ro", command)
            self.assertIn("pkgcheck scan --exit GentooCI", command[-1])

    def test_project_repo_list_matches_metadata_layout(self):
        root = Path(__file__).resolve().parent.parent
        repos = parse_repositories((root / ".pkgcheck-repos").read_text())
        masters = read_masters((root / "metadata/layout.conf").read_text())
        validate_masters(repos, masters)


if __name__ == "__main__":
    unittest.main()
