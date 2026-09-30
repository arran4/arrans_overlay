import importlib.util
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
			# Should update successfully
			rc = generator.update_ebuild(fake_ebuild, generator.render_pub_deps({}), check=False)
			self.assertEqual(rc, 0)
			content = fake_ebuild.read_text()
			self.assertIn("flutter-material-fonts", content)

			# Running with check=True on synchronized file returns 0
			rc_check = generator.update_ebuild(fake_ebuild, generator.render_pub_deps({}), check=True)
			self.assertEqual(rc_check, 0)

			# Desynchronized file with check=True returns 1
			fake_ebuild.write_text(
				f"EAPI=8\n{generator.BEGIN}\nstale\n{generator.END}\n"
			)
			rc_stale = generator.update_ebuild(fake_ebuild, generator.render_pub_deps({}), check=True)
			self.assertEqual(rc_stale, 1)





	def test_fetch_pub_deps(self):
		import os
		if "CI" not in os.environ:
			try:
				deps = generator.fetch_pub_deps("3.47.2")
				self.assertEqual(len(deps), 101, "3.47.2 should have exactly 101 hosted pub deps")
				self.assertIn("analyzer", deps)
				self.assertNotIn("flutter", deps)
				self.assertNotIn("flutter_test", deps)
			except RuntimeError as e:
				self.skipTest(f"Failed to fetch real pubspec.lock: {e}")

	@unittest.mock.patch('subprocess.Popen')
	def test_fetch_pub_deps_mocked(self, mock_popen):
		class MockProcess:
			def __init__(self, out, err, rc):
				self.stdout = type('obj', (object,), {'close': lambda: None})
				self._out = out
				self._err = err
				self.returncode = rc
			def communicate(self):
				return self._out, self._err
			def wait(self):
				return self.returncode

		mock_popen.side_effect = [
			MockProcess(b"", b"", 0),
			MockProcess(b"packages:\n  foo:\n    source: hosted\n    version: 1.0.0\n", b"", 0)
		]
		deps = generator.fetch_pub_deps("1.0.0")
		self.assertEqual(deps, {"foo": "1.0.0"})

		mock_popen.side_effect = [
			MockProcess(b"", b"", 0),
			MockProcess(b"", b"", 0)
		]
		with self.assertRaisesRegex(RuntimeError, "Extracted pubspec.lock is empty"):
			generator.fetch_pub_deps("1.0.0")

		mock_popen.side_effect = [
			MockProcess(b"", b"", 0),
			MockProcess(b"packages:\n  foo:\n    source: sdk\n    version: 1.0.0\n", b"", 0)
		]
		with self.assertRaisesRegex(RuntimeError, "No hosted packages found in pubspec.lock"):
			generator.fetch_pub_deps("1.0.0")

		mock_popen.side_effect = [
			MockProcess(b"", b"", 0),
			MockProcess(b"", b"Not found in archive", 2)
		]
		with self.assertRaisesRegex(RuntimeError, "Failed to extract pubspec.lock"):
			generator.fetch_pub_deps("1.0.0")
		self.assertEqual(deps, {"foo": "1.0.0"})

		mock_popen.side_effect = [
			MockProcess(b"", b"", 0),
			MockProcess(b"", b"", 0)
		]
		with self.assertRaisesRegex(RuntimeError, "Extracted pubspec.lock is empty"):
			generator.fetch_pub_deps("1.0.0")

		mock_popen.side_effect = [
			MockProcess(b"", b"", 0),
			MockProcess(b"packages:\n  foo:\n    source: sdk\n    version: 1.0.0\n", b"", 0)
		]
		with self.assertRaisesRegex(RuntimeError, "No hosted packages found in pubspec.lock"):
			generator.fetch_pub_deps("1.0.0")

		mock_popen.side_effect = [
			MockProcess(b"", b"", 0),
			MockProcess(b"", b"Not found in archive", 2)
		]
		with self.assertRaisesRegex(RuntimeError, "Failed to extract pubspec.lock"):
			generator.fetch_pub_deps("1.0.0")

if __name__ == "__main__":
	unittest.main()
