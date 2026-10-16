#!/usr/bin/env python3
"""Disable emoji candidates and emoji shortcuts in the Rime user directory."""

from __future__ import annotations

import re
import sys
from pathlib import Path


def edit(path: Path, transform) -> None:
    original = path.read_text(encoding="utf-8")
    updated = transform(original)
    if updated != original:
        path.write_text(updated, encoding="utf-8")


def disable_schema(text: str) -> str:
    text = re.sub(r"(?m)^  - name: emoji\n(?:    .*\n)+", "", text)
    text = re.sub(r"(?m)^    - simplifier@emoji[^\n]*\n", "", text)
    text = re.sub(r"(?ms)^# Emoji\nemoji:\n.*?(?=^# 简繁切换\n)", "", text)
    text = text.replace("置顶候选项 > Emoji > 简繁切换", "置顶候选项 > 简繁切换")
    text = text.replace("长词优先 > Emoji", "长词优先 > 简繁切换")
    return text


def disable_symbols(text: str) -> str:
    text = re.sub(r"(?m)^#表情\n", "", text)
    text = re.sub(r"(?m)^  '(?:vbq|Vbq|vvv)':.*\n", "", text)
    return text.replace("如自己常用的 emoji", "如自己常用的符号")


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: disable_emoji.py RIME_USER_DIR", file=sys.stderr)
        return 2

    root = Path(sys.argv[1])
    schemas = [
        root / "rime_ice.schema.yaml",
        root / "t9.schema.yaml",
        *sorted(root.glob("double_pinyin*.schema.yaml")),
    ]
    for path in schemas:
        edit(path, disable_schema)
    edit(root / "rime_ice.custom.yaml", lambda text: text.replace("    - simplifier@emoji\n", ""))
    edit(root / "others/fcitx4/legacy_no_lua/rime_ice.custom.yaml", lambda text: text.replace("    - simplifier@emoji\n", ""))
    edit(root / "default.yaml", lambda text: text.replace("    - emoji\n", ""))
    for name in ("symbols_v.yaml", "symbols_caps_v.yaml"):
        edit(root / name, disable_symbols)

    cases = root / "others/script/smoke/cases/rime_ice/input_cases.tsv"
    if cases.exists():
        edit(cases, lambda text: "".join(
            line for line in text.splitlines(keepends=True) if "基础：Emoji输入" not in line
        ))

    print(f"Emoji candidates disabled in {len(schemas)} Rime schemas")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
