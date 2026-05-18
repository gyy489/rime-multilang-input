#!/usr/bin/env python3
"""Build compact translation comment tables for the Rime Lua filter."""

from __future__ import annotations

import csv
import re
import sys
from pathlib import Path


CHINESE_RE = re.compile(r"[\u3400-\u9fff]")
CEDICT_RE = re.compile(r"^(\S+)\s+(\S+)\s+\[[^\]]+\]\s+/(.+)/$")
POS_RE = re.compile(
    r"^(?:interj|int|n|v|vi|vt|adj|adv|prep|pron|conj|num|art|aux|abbr|pl|sing|a|erj)\.?\s*",
    re.IGNORECASE,
)


def clean_zh_translation(text: str, max_chars: int = 28) -> str:
    text = text.replace("\\n", "\n")
    parts: list[str] = []
    for line in text.splitlines():
        line = re.sub(r"\[[^\]]+\]", "", line)
        for part in re.split(r"[；;，,]", line):
            part = POS_RE.sub("", part.strip(" ，,。:：;；"))
            if CHINESE_RE.search(part) and part not in parts:
                parts.append(part)
            if len(parts) >= 1:
                break
        if len(parts) >= 1:
            break
    result = "；".join(parts)
    if len(result) > max_chars:
        result = result[: max_chars - 1] + "…"
    return result


def clean_en_definition(definition: str, max_chars: int = 24) -> str:
    for part in definition.split("/"):
        part = part.strip()
        if not part:
            continue
        part = re.sub(r"\([^)]*\)", "", part)
        part = re.sub(r"\[[^\]]*\]", "", part)
        part = part.strip(" ;,")
        lowered = part.lower()
        if lowered.startswith(
            (
                "surname ",
                "variant of ",
                "old variant of ",
                "classifier for ",
                "cl:",
            )
        ):
            continue
        part = re.split(r"[;,]", part, maxsplit=1)[0].strip()
        if part:
            if len(part) > max_chars:
                part = part[: max_chars - 1] + "…"
            return part
    return ""


def iter_rime_words(path: Path) -> set[str]:
    words: set[str] = set()
    in_body = False
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if line == "...":
            in_body = True
            continue
        if not in_body or not line or line.startswith("#"):
            continue
        words.add(line.split("\t", 1)[0].strip())
    return words


def collect_english_candidates(user_data: Path) -> set[str]:
    words: set[str] = set()
    for path in sorted((user_data / "en_dicts").glob("*.dict.yaml")):
        for word in iter_rime_words(path):
            if re.search(r"[A-Za-z]", word):
                words.add(word.lower())
    return words


def collect_chinese_candidates(user_data: Path) -> set[str]:
    words: set[str] = set()
    paths = list((user_data / "cn_dicts").glob("*.dict.yaml")) + [user_data / "rime_ice.dict.yaml"]
    for path in paths:
        if not path.exists():
            continue
        for word in iter_rime_words(path):
            if CHINESE_RE.search(word) and len(word) >= 2:
                words.add(word)
    return words


def build_en_zh(ecdict_csv: Path, english_words: set[str], output: Path) -> int:
    rows: dict[str, str] = {}
    with ecdict_csv.open("r", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle)
        for row in reader:
            word = (row.get("word") or "").strip().lower()
            if word not in english_words or word in rows:
                continue
            translation = clean_zh_translation(row.get("translation") or "")
            if translation:
                rows[word] = translation

    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open("w", encoding="utf-8", newline="\n") as handle:
        for word in sorted(rows):
            handle.write(f"{word}\t{rows[word]}\n")
    return len(rows)


def build_zh_en(cedict_file: Path, chinese_words: set[str], output: Path) -> int:
    rows: dict[str, str] = {}
    for raw_line in cedict_file.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        match = CEDICT_RE.match(line)
        if not match:
            continue
        traditional, simplified, definition = match.groups()
        meaning = clean_en_definition(definition)
        if not meaning:
            continue
        for word in (simplified, traditional):
            if word in chinese_words and word not in rows:
                rows[word] = meaning

    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open("w", encoding="utf-8", newline="\n") as handle:
        for word in sorted(rows):
            handle.write(f"{word}\t{rows[word]}\n")
    return len(rows)


def load_tsv(path: Path) -> dict[str, str]:
    rows: dict[str, str] = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.strip() or line.startswith("#"):
            continue
        try:
            key, value = line.split("\t", 1)
        except ValueError:
            continue
        rows[key] = value
    return rows


def write_tsv(path: Path, rows: dict[str, str]) -> None:
    with path.open("w", encoding="utf-8", newline="\n") as handle:
        for key in sorted(rows):
            handle.write(f"{key}\t{rows[key]}\n")


def apply_overrides(out_dir: Path) -> tuple[int, int]:
    overrides = out_dir / "custom.tsv"
    if not overrides.exists():
        return 0, 0

    en_path = out_dir / "en_zh.tsv"
    zh_path = out_dir / "zh_en.tsv"
    en_rows = load_tsv(en_path)
    zh_rows = load_tsv(zh_path)
    en_count = 0
    zh_count = 0

    for raw_line in overrides.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split("\t")
        if len(parts) != 3:
            continue
        lang, key, value = parts
        if lang == "en" and key and value:
            en_rows[key.lower()] = value
            en_count += 1
        elif lang == "zh" and key and value:
            zh_rows[key] = value
            zh_count += 1

    write_tsv(en_path, en_rows)
    write_tsv(zh_path, zh_rows)
    return en_count, zh_count


def main() -> int:
    if len(sys.argv) != 5:
        print(
            "usage: build_translation_comments.py USER_DATA ECDICT_CSV CEDICT_U8 OUT_DIR",
            file=sys.stderr,
        )
        return 2

    user_data = Path(sys.argv[1])
    ecdict_csv = Path(sys.argv[2])
    cedict_file = Path(sys.argv[3])
    out_dir = Path(sys.argv[4])

    english_words = collect_english_candidates(user_data)
    chinese_words = collect_chinese_candidates(user_data)
    en_count = build_en_zh(ecdict_csv, english_words, out_dir / "en_zh.tsv")
    zh_count = build_zh_en(cedict_file, chinese_words, out_dir / "zh_en.tsv")
    en_overrides, zh_overrides = apply_overrides(out_dir)
    print(
        f"wrote {en_count} English translations and {zh_count} Chinese translations "
        f"({en_overrides} English overrides, {zh_overrides} Chinese overrides)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
