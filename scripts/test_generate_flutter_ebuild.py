import importlib.util
import os
from pathlib import Path
import sys
import tempfile
import unittest
import unittest.mock

GENERATOR = Path(__file__).with_name("generate_flutter_ebuild.py")
SPEC = importlib.util.spec_from_file_location(
	"flutter_ebuild_generator", GENERATOR
)
assert SPEC is not None and SPEC.loader is not None
generator = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = generator
SPEC.loader.exec_module(generator)


class GenerateFlutterEbuildTest(unittest.TestCase):
	def test_pub_dependencies_contain_required_packages(self):
		deps = generator.PUB_DEPENDENCIES
		self.assertIn("analyzer", deps)
		self.assertIn("args", deps)
		self.assertIn("dds", deps)
		self.assertIn("file", deps)
		self.assertIn("meta", deps)
		self.assertIn("path", deps)
		self.assertIn("process", deps)
		self.assertIn("shelf", deps)
		self.assertIn("test", deps)
		self.assertIn("yaml", deps)
		self.assertGreaterEqual(len(deps), 100)

	def test_render_pub_deps_block_format(self):
		rendered = generator.render_pub_deps({})
		self.assertTrue(rendered.startswith(generator.BEGIN))
		self.assertTrue(rendered.endswith(generator.END))
		self.assertIn("https://github.com/flutter/flutter/archive", rendered)
		self.assertIn("flutter-material-fonts-3012db47.zip", rendered)
		self.assertIn("flutter-gradle-wrapper-fd5c1f2c.tgz", rendered)
		self.assertIn("PUB_URI=\"https://pub.dev/api/archives\"", rendered)

	def test_render_pub_deps_line_lengths(self):
		rendered = generator.render_pub_deps({})
		for index, line in enumerate(rendered.splitlines(), 1):
			self.assertLessEqual(
				len(line.expandtabs(4)),
				120,
				f"Line {index} exceeds 120 chars: {line}",
			)

	def test_update_ebuild_sync_check(self):
		with tempfile.TemporaryDirectory() as tmpdir:
			fake_ebuild = Path(tmpdir) / "flutter-3.47.2.ebuild"
			fake_ebuild.write_text(
				f"EAPI=8\n{generator.BEGIN}\nold_content\n{generator.END}\n"
			)
			rc = generator.update_ebuild(fake_ebuild, generator.render_pub_deps({}), check=False)
			self.assertEqual(rc, 0)
			content = fake_ebuild.read_text()
			self.assertIn("flutter-material-fonts", content)

			rc_check = generator.update_ebuild(fake_ebuild, generator.render_pub_deps({}), check=True)
			self.assertEqual(rc_check, 0)

			fake_ebuild.write_text(
				f"EAPI=8\n{generator.BEGIN}\nstale\n{generator.END}\n"
			)
			rc_stale = generator.update_ebuild(fake_ebuild, generator.render_pub_deps({}), check=True)
			self.assertEqual(rc_stale, 1)

	def test_fixture_has_exact_flutter_3_47_2_hosted_mapping(self):
		"""This deterministic fixture is the non-skippable parser acceptance test."""
		lines = ["packages:"]
		for package, version in generator.PUB_DEPENDENCIES.items():
			lines.extend([f"  {package}:", "    source: hosted", f"    version: {version}"])
		# SDK/path entries are intentionally internal and do not enter SRC_URI.
		lines.extend(["  flutter:", "    source: sdk", "    version: 0.0.0"])
		deps = generator.parse_pub_deps_lockfile("\n".join(lines) + "\n")
		self.assertEqual(len(deps), 101)
		self.assertEqual(deps, generator.PUB_DEPENDENCIES)

	@unittest.skipUnless(os.environ.get("FLUTTER_RELEASE_NETWORK_TEST") == "1", "network release check is opt-in")
	def test_fetch_pub_deps_network_release(self):
		self.assertEqual(generator.fetch_pub_deps("3.47.2"), generator.PUB_DEPENDENCIES)

	@unittest.mock.patch('subprocess.run')
	def test_fetch_pub_deps_mocked(self, mock_run):
		def cp(stdout=b"", stderr=b"", rc=0):
			return unittest.mock.Mock(stdout=stdout, stderr=stderr, returncode=rc)

		lock = b"packages:\n  foo:\n    source: hosted\n    version: 1.0.0\n"
		mock_run.side_effect = [cp(), cp(stdout=lock)]
		deps = generator.fetch_pub_deps("1.0.0")
		self.assertEqual(deps, {"foo": "1.0.0"})

		mock_run.side_effect = [cp(), cp(stdout=b"")]
		with self.assertRaisesRegex(RuntimeError, "Extracted pubspec.lock is empty"):
			generator.fetch_pub_deps("1.0.0")

		mock_run.side_effect = [cp(), cp(stdout=b"packages:\n  foo:\n    source: sdk\n    version: 1.0.0\n")]
		with self.assertRaisesRegex(RuntimeError, "No hosted packages found in pubspec.lock"):
			generator.fetch_pub_deps("1.0.0")

		mock_run.side_effect = [cp(), cp(stderr=b"Not found in archive", rc=2)]
		with self.assertRaisesRegex(RuntimeError, "Failed to extract pubspec.lock"):
			generator.fetch_pub_deps("1.0.0")

		mock_run.side_effect = [cp(stderr=b"curl: (22) The requested URL returned error: 404", rc=22)]
		with self.assertRaisesRegex(RuntimeError, r"curl failed: curl: \(22\)"):
			generator.fetch_pub_deps("1.0.0")

	@unittest.mock.patch('subprocess.run')
	def test_fetch_pub_deps_rejects_git_source(self, mock_run):
		def cp(stdout=b"", stderr=b"", rc=0):
			return unittest.mock.Mock(stdout=stdout, stderr=stderr, returncode=rc)

		lock = (
			b"packages:\n"
			b"  foo:\n    source: hosted\n    version: 1.0.0\n"
			b"  bar:\n    source: git\n    version: 2.0.0\n"
		)
		mock_run.side_effect = [cp(), cp(stdout=lock)]
		with self.assertRaisesRegex(RuntimeError, "Unsupported source type 'git' for package bar"):
			generator.fetch_pub_deps("1.0.0")

	@unittest.mock.patch('subprocess.run')
	def test_fetch_pub_deps_unsupported_source(self, mock_run):
		def cp(stdout=b"", stderr=b"", rc=0):
			return unittest.mock.Mock(stdout=stdout, stderr=stderr, returncode=rc)

		lock = (
			b"packages:\n"
			b"  foo:\n    source: hosted\n    version: 1.0.0\n"
			b"  bar:\n    source: unknown\n    version: 2.0.0\n"
		)
		mock_run.side_effect = [cp(), cp(stdout=lock)]
		with self.assertRaisesRegex(RuntimeError, "Unsupported source type 'unknown' for package bar"):
			generator.fetch_pub_deps("1.0.0")

if __name__ == "__main__":
	unittest.main()
