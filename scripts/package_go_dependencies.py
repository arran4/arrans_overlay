#!/usr/bin/env python3
"""Prepare a verified go-module.eclass distfile outside Portage build phases.

This deliberately downloads into a new cache. It never uses the caller's module
cache or lets Go download a compiler. The source go.mod/go.sum remain unchanged;
the archive includes the expanded checksums separately under go-deps/.
"""

import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import tarfile
import tempfile


def json_records(value):
    decoder = json.JSONDecoder()
    while value.strip():
        value = value.lstrip()
        record, end = decoder.raw_decode(value)
        yield record
        value = value[end:]


def archive_filter(info):
    """Normalize metadata and omit mutable proxy/checksum-service bookkeeping."""
    parts = Path(info.name).parts
    if info.name.startswith("go-mod/cache/download/"):
        if "sumdb" in parts or info.name.endswith(".lock") or parts[-1] == "list":
            return None
    if not (info.isfile() or info.isdir()):
        raise ValueError(f"Non-regular cache entry: {info.name}")
    if "golang.org/toolchain@" in info.name or "golang.org/toolchain/" in info.name:
        raise ValueError(f"Downloaded toolchain in cache: {info.name}")
    info.uid = info.gid = info.mtime = 0
    info.uname = info.gname = ""
    info.mode = 0o755 if info.isdir() or info.mode & 0o111 else 0o644
    info.pax_headers = {}
    return info


def package(source, output, go):
    if output.exists():
        raise FileExistsError(f"Refusing to replace {output}")
    go = shutil.which(go)
    if not go:
        raise ValueError("Go executable not found")
    output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="go-deps-") as temporary:
        root = Path(temporary)
        project = root / "go-deps"
        project.mkdir()
        for filename in ("go.mod", "go.sum"):
            shutil.copyfile(source / filename, project / filename)
        env = os.environ.copy()
        env.update(
            GOENV="off", GOWORK="off", GOFLAGS="", GOTOOLCHAIN="local",
            GOPATH=str(root / "go-path"), GOCACHE=str(root / "go-build"),
            GOMODCACHE=str(root / "go-mod"),
            GOPROXY="https://proxy.golang.org", GOSUMDB="sum.golang.org",
            GOPRIVATE="", GONOPROXY="", GONOSUMDB="", GOINSECURE="", GOVCS="*:off",
        )

        def run(*args):
            return subprocess.run(
                [go, *args], cwd=project, env=env, check=True,
                text=True, stdout=subprocess.PIPE,
            ).stdout

        print("Downloading the complete module graph into a fresh cache", flush=True)
        records = list(json_records(run("mod", "download", "-modcacherw", "-json", "all")))
        for record in records:
            if record.get("Error") or record["Path"] == "golang.org/toolchain":
                raise ValueError(f"Invalid module download: {record}")
        env.update(GOPROXY="off", GOSUMDB="off")
        print(run("mod", "verify").strip(), flush=True)
        run("list", "-mod=readonly", "-m", "-json", "all")
        metadata = {
            "generated_by": "scripts/package_go_dependencies.py",
            "go_version": run("version").strip(),
            "modules": sorted(
                [{key: item[key] for key in ("Path", "Version", "Sum", "GoModSum")}
                 for item in records], key=lambda item: (item["Path"], item["Version"]),
            ),
        }
        (project / "modules.json").write_text(json.dumps(metadata, indent=2) + "\n")
        print(f"Packaging {len(records)} verified modules", flush=True)
        # Keep incomplete output invisible, including on compressor failure.
        with tempfile.TemporaryDirectory(prefix=".go-deps-", dir=output.parent) as stage:
            archive = Path(stage) / output.name
            with archive.open("wb") as destination:
                compressor = subprocess.Popen(["xz", "-T2", "-9", "-c"], stdout=destination,
                                              stdin=subprocess.PIPE)
                try:
                    with tarfile.open(fileobj=compressor.stdin, mode="w|",
                                      format=tarfile.PAX_FORMAT) as tar:
                        for name in ("go-deps", "go-mod"):
                            tar.add(root / name, arcname=name, filter=archive_filter)
                    compressor.stdin.close()
                    if compressor.wait():
                        raise RuntimeError("xz compression failed")
                finally:
                    if compressor.poll() is None:
                        compressor.terminate()
                        compressor.wait()
            # A hard link publishes atomically and cannot overwrite an existing file.
            os.link(archive, output)
        print(output, flush=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, help="Upstream source directory with go.mod/go.sum")
    parser.add_argument("output", type=Path, help="New dependency archive (.tar.xz)")
    parser.add_argument("--go", default="go", help="Installed Go executable; never downloaded")
    args = parser.parse_args()
    if not args.output.name.endswith(".tar.xz"):
        parser.error("output must end in .tar.xz")
    package(args.source.resolve(), args.output.resolve(), args.go)
