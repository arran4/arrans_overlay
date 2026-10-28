#!/usr/bin/env python3
"""Validated identity shared by the Flutter and Engine source generators."""

from __future__ import annotations

from dataclasses import asdict, dataclass
import json
from pathlib import Path
import re


SHA = re.compile(r"[0-9a-f]{40}\Z")
VERSION = re.compile(r"\d+\.\d+\.\d+(-r\d+)?\Z")
BASE_VERSION = re.compile(r"\d+\.\d+\.\d+\Z")


@dataclass(frozen=True)
class FlutterReleaseSpec:
    """Everything which identifies one reviewed Flutter source release."""

    version: str
    framework_revision: str
    engine_revision: str
    dart_revision: str
    dart_sdk_version: str
    material_fonts_revision: str
    gradle_wrapper_revision: str
    release_date: str
    host_dart_constraint: str
    framework_commit_date: str = ""
    engine_commit_date: str = ""

    @property
    def base_version(self) -> str:
        return self.version.split("-r")[0]

    def validate(self) -> None:
        if not VERSION.fullmatch(self.version):
            raise ValueError(f"invalid Flutter version: {self.version!r}")
        if not BASE_VERSION.fullmatch(self.dart_sdk_version):
            raise ValueError(
                f"invalid Flutter Dart SDK version: {self.dart_sdk_version!r}"
            )
        for field in (
            "framework_revision", "engine_revision", "dart_revision",
            "material_fonts_revision", "gradle_wrapper_revision",
        ):
            value = getattr(self, field)
            if not SHA.fullmatch(value):
                raise ValueError(f"invalid {field}: {value!r}")
        if not self.release_date:
            raise ValueError("Flutter release date is missing")
        if not self.host_dart_constraint:
            raise ValueError("Flutter host Dart constraint is missing")

    @classmethod
    def from_dict(cls, source: dict[str, object]) -> "FlutterReleaseSpec":
        fields = {}
        for field in cls.__dataclass_fields__:
            val = source.get(field)
            if val is None and field in ("framework_commit_date", "engine_commit_date"):
                val = ""
            fields[field] = val
        if any(not isinstance(value, str) for value in fields.values()):
            raise ValueError("release spec is missing a required string field")
        result = cls(**fields)  # type: ignore[arg-type]
        result.validate()
        return result

    @classmethod
    def read(cls, path: Path) -> "FlutterReleaseSpec":
        try:
            source = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as exc:
            raise ValueError(f"cannot read release spec {path}: {exc}") from exc
        if not isinstance(source, dict):
            raise ValueError("release spec must be a JSON object")
        return cls.from_dict(source)

    def write(self, path: Path) -> None:
        self.validate()
        path.write_text(
            json.dumps(asdict(self), indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )
