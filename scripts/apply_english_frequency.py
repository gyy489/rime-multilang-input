#!/usr/bin/env python3
"""Apply convex corpus weights to entries already present in en.dict.yaml."""

from __future__ import annotations

import sys
from pathlib import Path


BASE_WEIGHT = 100
PEAK_WEIGHT = 1_000_000
CURVE_POWER = 1.5


def load_counts(path: Path) -> dict[str, int]:
    counts: dict[str, int] = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        try:
            word, value = line.rsplit(maxsplit=1)
            count = int(value)
        except ValueError:
            continue
        if word.isascii() and word.isalpha() and count > 0:
            key = word.lower()
            counts[key] = max(counts.get(key, 0), count)
    return counts


def weight(count: int, maximum: int) -> int:
    if count == 0:
        return BASE_WEIGHT
    return BASE_WEIGHT + round(PEAK_WEIGHT * (count / maximum) ** CURVE_POWER)


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: apply_english_frequency.py SOURCE_EN_50K EN_DICT", file=sys.stderr)
        return 2

    source, target = map(Path, sys.argv[1:])
    counts = load_counts(source)
    maximum = max(counts.values())
    lines = target.read_text(encoding="utf-8").splitlines(keepends=True)
    result: list[str] = []
    in_entries = False
    weighted = 0

    for line in lines:
        if line.strip() == "...":
            in_entries = True
            result.append(line)
            continue
        if not in_entries or line.startswith("#") or "\t" not in line:
            result.append(line)
            continue
        fields = line.rstrip("\r\n").split("\t")
        if len(fields) not in (2, 3):
            raise ValueError(f"unexpected dictionary entry: {line.rstrip()}")
        text, code = fields[:2]
        count = counts.get(text.lower(), 0) if code.lower() == text.lower() else 0
        weighted += count > 0
        result.append(f"{text}\t{code}\t{weight(count, maximum)}\n")

    target.write_text("".join(result), encoding="utf-8", newline="\n")
    print(f"weighted {weighted} English entries in {target}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
