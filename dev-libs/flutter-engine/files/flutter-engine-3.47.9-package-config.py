#!/usr/bin/env python3
"""Synthesize Flutter Engine root .dart_tool/package_config.json.

Upstream GN rules for snapshot targets (such as tools/const_finder) default
to looking for //flutter/.dart_tool/package_config.json. In the offline Gentoo
build, Dart SDK package resolution runs in flutter/third_party/dart.
This script re-roots the resolved Dart SDK package paths and declares the Engine
workspace packages for offline compilation.
"""

import json
import os
import sys


def main() -> int:
    dart_cfg_path = (
        sys.argv[1]
        if len(sys.argv) > 1
        else "flutter/third_party/dart/.dart_tool/package_config.json"
    )
    engine_cfg_path = (
        sys.argv[2]
        if len(sys.argv) > 2
        else "flutter/.dart_tool/package_config.json"
    )

    if not os.path.exists(dart_cfg_path):
        sys.stderr.write(f"Error: {dart_cfg_path} does not exist\n")
        return 1

    with open(dart_cfg_path, "r", encoding="utf-8") as f:
        dart_cfg = json.load(f)

    packages = []
    for pkg in dart_cfg.get("packages", []):
        p = dict(pkg)
        root_uri = p.get("rootUri", "")
        if root_uri.startswith("../"):
            p["rootUri"] = "../third_party/dart/" + root_uri[3:]
        packages.append(p)

    def entry(name: str, root_uri: str) -> dict:
        return {
            "name": name,
            "rootUri": root_uri,
            "packageUri": "lib/",
            "languageVersion": "3.5",
        }

    packages.append(entry("const_finder", "../tools/const_finder"))
    packages.append(
        entry("flutter_frontend_server", "../flutter_frontend_server")
    )
    packages.append(entry("_engine_workspace", "../"))

    engine_cfg = {
        "configVersion": 2,
        "packages": packages,
        "generator": "pub",
    }

    os.makedirs(os.path.dirname(engine_cfg_path), exist_ok=True)
    with open(engine_cfg_path, "w", encoding="utf-8") as f:
        json.dump(engine_cfg, f, indent=2)

    return 0


if __name__ == "__main__":
    sys.exit(main())
