import io
import os
from pathlib import Path
import sys
import tarfile
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
from package_go_dependencies import archive_filter, json_records, package


class GoDependencyArchiveTests(unittest.TestCase):
    def test_existing_archive_is_never_replaced(self):
        with tempfile.TemporaryDirectory() as directory:
            archive = Path(directory) / "existing.tar.xz"
            archive.write_bytes(b"preserved")
            with self.assertRaises(FileExistsError):
                package(Path(directory), archive, "nonexistent-go")
            self.assertEqual(archive.read_bytes(), b"preserved")

    def test_go_stream_has_multiple_records(self):
        records = list(json_records(' {"Path":"a"}\n\n{"Path":"b"}\n'))
        self.assertEqual([item["Path"] for item in records], ["a", "b"])

    def test_rejects_downloaded_toolchains_and_links(self):
        for name in (
            "go-mod/golang.org/toolchain@v0.0.1/bin/go",
            "go-mod/cache/download/golang.org/toolchain/@v/v0.0.1.zip",
        ):
            with self.subTest(name=name), self.assertRaises(ValueError):
                archive_filter(tarfile.TarInfo(name))
        entry = tarfile.TarInfo("go-mod/example.org/pkg@v1.0.0/link")
        entry.type = tarfile.SYMTYPE
        entry.linkname = "/outside-cache"
        with self.assertRaises(ValueError):
            archive_filter(entry)

    def test_drops_bookkeeping_but_preserves_module_checksum_files(self):
        prefix = "go-mod/cache/download/"
        for name in ("sumdb/sum.golang.org/latest", "example.org/a/@v/list",
                     "example.org/a/@v/v1.0.0.lock"):
            self.assertIsNone(archive_filter(tarfile.TarInfo(prefix + name)))
        for suffix in ("zip", "ziphash", "mod", "info"):
            entry = tarfile.TarInfo(prefix + "example.org/a/@v/v1.0.0." + suffix)
            self.assertIsNotNone(archive_filter(entry))

    def test_archive_is_independent_of_source_metadata(self):
        archives = []
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / "source.go"
            source.write_text("package example\n")
            for timestamp, mode in ((123, 0o600), (456, 0o444)):
                source.chmod(mode)
                os.utime(source, (timestamp, timestamp))
                output = io.BytesIO()
                with tarfile.open(fileobj=output, mode="w", format=tarfile.PAX_FORMAT) as tar:
                    tar.add(source, arcname="go-mod/example.org/a@v1.0.0/source.go",
                            filter=archive_filter)
                archives.append(output.getvalue())
        self.assertEqual(*archives)


if __name__ == "__main__":
    unittest.main()
