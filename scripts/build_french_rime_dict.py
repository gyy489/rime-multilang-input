#!/usr/bin/env python3
"""Build a Rime table dictionary from the French FrequencyWords list."""

from __future__ import annotations

import re
import sys
import unicodedata
from pathlib import Path


TOKEN_RE = re.compile(r"^[A-Za-zÀ-ÖØ-öø-ÿŒœÆæ'’.-]+$")
REPLACEMENTS = {
    "œ": "oe",
    "Œ": "oe",
    "æ": "ae",
    "Æ": "ae",
}


def ascii_code(word: str) -> str:
    normalized = word
    for original, replacement in REPLACEMENTS.items():
        normalized = normalized.replace(original, replacement)
    normalized = unicodedata.normalize("NFKD", normalized)
    normalized = "".join(ch for ch in normalized if not unicodedata.combining(ch))
    normalized = normalized.lower()
    return re.sub(r"[^a-z]", "", normalized)


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: build_french_rime_dict.py SOURCE_FR_50K OUT_DICT", file=sys.stderr)
        return 2

    source = Path(sys.argv[1])
    output = Path(sys.argv[2])
    seen: set[tuple[str, str]] = set()
    rows: list[tuple[str, str, int]] = []

    for line in source.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        try:
            word, count_text = line.rsplit(maxsplit=1)
            count = int(count_text)
        except ValueError:
            continue
        word = word.strip()
        if not TOKEN_RE.match(word):
            continue
        code = ascii_code(word)
        if not code:
            continue
        key = (word, code)
        if key in seen:
            continue
        seen.add(key)
        rows.append((word, code, count))

    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open("w", encoding="utf-8", newline="\n") as handle:
        handle.write("# Rime dictionary\n")
        handle.write("# encoding: utf-8\n")
        handle.write("#\n")
        handle.write("# French candidates generated from hermitdave/FrequencyWords\n")
        handle.write("# Source: content/2018/fr/fr_50k.txt, content license CC BY-SA 4.0\n")
        handle.write("# Codes are ASCII-folded, so `francais` can produce `français`.\n")
        handle.write("\n---\n")
        handle.write('name: fr\nversion: "2026-05-16"\n')
        handle.write("sort: by_weight\nuse_preset_vocabulary: false\n")
        handle.write("columns:\n  - text\n  - code\n  - weight\n...\n")
        for word, code, count in rows:
            handle.write(f"{word}\t{code}\t{count}\n")

    print(f"wrote {len(rows)} entries to {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
