#!/usr/bin/env python3
"""Summarise a redirected Portage log without printing verbose build output.

Run inside the Gentoo stage3 container while emerge writes to --log. The
calling shell creates --done after emerge exits; the reader drains any final
output before stopping, including on build failures.
"""

import argparse
import re
import time
from pathlib import Path

ANSI = re.compile(r"\x1b\[[0-?]*[ -/]*[@-~]")
PACKAGE = re.compile(
    r"^>>>\s+(?P<action>Emerging(?: binary)?|Completed|Failed to emerge)"
    r"\s+\((?P<current>\d+) of (?P<total>\d+)\)\s+(?P<package>\S+)"
)
SYNC = re.compile(r"^>>>\s+Syncing repository\s+(.+)")
TOTAL = re.compile(r"^Total:\s+(.+)")


def format_size(byte_count):
    if byte_count < 1024:
        return f"{byte_count} B"
    if byte_count < 1048576:
        return f"{byte_count / 1024:.1f} KiB"
    return f"{byte_count / 1048576:.1f} MiB"


class Summary:
    def __init__(self, label):
        self.label = label
        self.latest = "waiting for package information"
        self.last_event = None

    def parse(self, line):
        line = ANSI.sub("", line).strip()
        match = PACKAGE.match(line)
        if match:
            action = match["action"]
            package = match["package"]
            self.latest = f'{match["current"]}/{match["total"]} {package}'
            event = (action, self.latest)
            if event == self.last_event:
                return None
            self.last_event = event
            status = {
                "Emerging": "building",
                "Emerging binary": "installing binary",
                "Completed": "completed",
                "Failed to emerge": "failed",
            }[action]
            return f"{self.latest}: {status}"
        match = SYNC.match(line)
        if match:
            description = match.group(1)[:150]
            self.latest = f"syncing {description}"
            return self.latest
        match = TOTAL.match(line)
        if match:
            return f'plan: {match.group(1)[:150]}'
        return None

    def show(self, event):
        if event is not None:
            print(f"[emerge:{self.label}] {event}", flush=True)


def monitor(log_file, done_file, label, heartbeat_seconds):
    summary = Summary(label)
    started = time.monotonic()
    last_heartbeat = started
    consumed = 0
    remainder = b""
    with log_file.open("rb", buffering=0) as log:
        while True:
            data = log.read(65536)
            if data:
                consumed += len(data)
                remainder += data.replace(b"\r", b"\n")
                *lines, remainder = remainder.split(b"\n")
                for line in lines:
                    summary.show(summary.parse(line.decode("utf-8", "replace")))
                # Compiler tools can write long lines without a newline.
                # Keep memory bounded; Portage milestone lines are short.
                if len(remainder) > 16384:
                    remainder = remainder[-16384:]
                continue
            if done_file.exists():
                if remainder:
                    summary.show(summary.parse(remainder.decode("utf-8", "replace")))
                return
            now = time.monotonic()
            if now - last_heartbeat >= heartbeat_seconds:
                print(
                    f"[emerge:{label}] {int(now - started)}s elapsed; "
                    f"{summary.latest}; {format_size(consumed)} archived",
                    flush=True,
                )
                last_heartbeat = now
            time.sleep(1)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--log", type=Path, required=True)
    parser.add_argument("--done", type=Path, required=True)
    parser.add_argument("--label", required=True)
    parser.add_argument("--heartbeat", type=int, default=120)
    args = parser.parse_args()
    if args.heartbeat <= 0:
        parser.error("--heartbeat must be positive")
    monitor(args.log, args.done, args.label, args.heartbeat)


if __name__ == "__main__":
    main()
