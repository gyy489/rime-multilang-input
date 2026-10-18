#!/usr/bin/env python3
"""Prepare a private Rime user-dictionary import from macOS learned Chinese phrases.

Only new, all-Han phrases of two or more characters are exported. Existing
Rime dictionary entries and words whose macOS reading cannot be segmented with
the active 8105 character table are skipped. Output files are created with
owner-only permissions and must not be committed to Git.
"""

from __future__ import annotations

import argparse
import os
import re
import sqlite3
from collections import defaultdict
from functools import lru_cache
from pathlib import Path


HAN_WORD = re.compile(r"[\u3400-\u9fff]{2,}")
PINYIN = re.compile(r"[a-z]+")
TABLES = ("8105", "thuocl_it", "base", "ext", "tencent", "others")


def entries(path: Path):
    started = False
    with path.open(encoding="utf-8-sig") as source:
        for line in source:
            if line.strip() == "...":
                started = True
            elif started and line.strip() and not line.startswith("#"):
                yield line.rstrip("\n").split("\t")


def read_dictionary(user_data: Path):
    words = set()
    characters = defaultdict(list)
    for table in TABLES:
        for row in entries(user_data / "cn_dicts" / f"{table}.dict.yaml"):
            word = row[0]
            words.add(word)
            if table == "8105" and len(word) == 1 and len(row) > 1 and PINYIN.fullmatch(row[1]):
                characters[word].append(row[1])
    return words, characters


def split_reading(reading: str, word: str, characters: dict[str, list[str]]):
    @lru_cache(None)
    def split(index: int, offset: int):
        if index == len(word):
            return () if offset == len(reading) else None
        for syllable in characters[word[index]]:
            if reading.startswith(syllable, offset):
                rest = split(index + 1, offset + len(syllable))
                if rest is not None:
                    return (syllable, *rest)
        return None

    result = split(0, 0)
    return " ".join(result) if result else None


def write_private(path: Path, lines: list[str]):
    path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    descriptor = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    with os.fdopen(descriptor, "w", encoding="utf-8") as output:
        output.writelines(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mac-db", type=Path,
                        default=Path.home() / "Library/Dictionaries/DynamicPhraseLexicon_zh_Hans.db")
    parser.add_argument("--user-data", type=Path, default=Path("user-data"))
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--name-corpus", type=Path)
    parser.add_argument("--names-output", type=Path)
    args = parser.parse_args()
    if bool(args.name_corpus) != bool(args.names_output):
        parser.error("--name-corpus and --names-output must be supplied together")

    existing, characters = read_dictionary(args.user_data)
    with sqlite3.connect(f"file:{args.mac_db}?mode=ro", uri=True) as database:
        learned = {(reading.decode("utf-16-le"), surface.decode("utf-16-le"))
                   for reading, surface in database.execute("SELECT Reading, Surface FROM Words")}

    output = {}
    skipped = 0
    for reading, word in learned:
        if word in existing or not HAN_WORD.fullmatch(word) or not PINYIN.fullmatch(reading):
            continue
        code = split_reading(reading, word, characters)
        if code:
            output[(word, code)] = True
        else:
            skipped += 1

    ordered = sorted(output)
    write_private(args.output, [f"{word}\t{code}\t1\n" for word, code in ordered])

    if args.name_corpus:
        known_names = {line.strip() for line in args.name_corpus.open(encoding="utf-8-sig")}
        names = sorted({word for word, _ in ordered if word in known_names})
        write_private(args.names_output, [f"cn\t{word}\n" for word in names])
        print(f"Prepared {len(ordered)} phrases, {len(names)} known names, {skipped} unreadable readings")
    else:
        print(f"Prepared {len(ordered)} phrases, {skipped} unreadable readings")


if __name__ == "__main__":
    main()
