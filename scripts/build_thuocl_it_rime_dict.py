#!/usr/bin/env python3
"""Build a Rime dictionary from THUOCL IT terms."""

from __future__ import annotations

import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: build_thuocl_it_rime_dict.py THUOCL_IT.txt OUT_DICT", file=sys.stderr)
        return 2

    source = Path(sys.argv[1])
    output = Path(sys.argv[2])
    rows: list[tuple[str, int]] = []
    seen: set[str] = set()

    for line in source.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line:
            continue
        parts = line.split()
        if len(parts) < 2:
            continue
        word = "".join(parts[:-1]).strip()
        try:
            weight = int(parts[-1])
        except ValueError:
            continue
        if word and word not in seen:
            seen.add(word)
            rows.append((word, weight))

    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open("w", encoding="utf-8", newline="\n") as handle:
        handle.write("# Rime dictionary\n")
        handle.write("# encoding: utf-8\n")
        handle.write("#\n")
        handle.write("# IT terms generated from THUOCL.\n")
        handle.write("# Source: https://github.com/thunlp/THUOCL\n")
        handle.write("\n---\n")
        handle.write('name: thuocl_it\nversion: "2016-12-24"\n')
        handle.write("sort: by_weight\n")
        handle.write("columns:\n  - text\n  - weight\n...\n")
        for word, weight in rows:
            handle.write(f"{word}\t{weight}\n")

    print(f"wrote {len(rows)} IT terms to {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
