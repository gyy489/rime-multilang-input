#!/usr/bin/env python3
"""Build a compact name index for candidates in the installed dictionaries.

Chinese/English names: wainshine/Chinese-Names-Corpus, commit
47d4af8d816f6212787ddfc49173cac3b994b58d (Apache-2.0).
French given names: INSEE Base prénoms 2024 (Licence Ouverte v2.0).
Common-word exclusions: CC-CEDICT and Lexique 3.83.

Sources:
https://github.com/wainshine/Chinese-Names-Corpus
https://www.data.gouv.fr/datasets/base-prenoms-2024-insee
https://www.lexique.org/databases/Lexique383/Lexique383.tsv

Regenerate with the pinned corpus checkout and Lexique TSV:
python3 scripts/generate_person_names.py --corpus /path/to/Chinese-Names-Corpus \
    --lexique /path/to/Lexique383.tsv
"""

from __future__ import annotations

import argparse
import csv
import re
from pathlib import Path


FRENCH_NAMES_WITH_COMMON_SPELLINGS = {"jean", "marie"}
FRENCH_NON_NAMES = {"france", "grace"}
ENGLISH_NON_NAMES = {"Africa", "Afghan", "Albania", "America", "Amsterdam", "May", "Paris"}
CHINESE_NON_NAMES = {
    "万多", "何意", "华西", "向东", "向南", "向西", "常会", "常来", "方可", "江东",
    "白光", "石林", "金光", "金鹰", "张大", "富得", "欧陆", "秦国", "楚国", "苏北", "黄海",
}
CHINESE_SHORT_TRANSLITERATIONS = {"安娜", "杰克", "汤姆", "玛丽", "约翰", "乔治", "迈克", "比尔"}
CHINESE_EXTRA_NAMES = {"小明"}


def read_lines(path: Path) -> set[str]:
    return {line.strip() for line in path.read_text(encoding="utf-8-sig").splitlines() if line.strip()}


def dictionary_words(path: Path) -> set[str]:
    words: set[str] = set()
    in_entries = False
    for line in path.open(encoding="utf-8-sig"):
        if line.strip() == "...":
            in_entries = True
        elif in_entries and not line.startswith("#") and "\t" in line:
            words.add(line.split("\t", 1)[0])
    return words


def cedict_common_words(path: Path) -> set[str]:
    common: set[str] = set()
    entry = re.compile(r"^\S+ (\S+) \[([^]]+)\] /")
    for line in path.open(encoding="utf-8-sig"):
        match = entry.match(line)
        if match and match[2][:1].islower():
            common.add(match[1])
    return common


def french_common_words(path: Path) -> set[str]:
    with path.open(encoding="utf-8-sig", newline="") as source:
        return {row["ortho"].lower() for row in csv.DictReader(source, delimiter="\t")}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--corpus", type=Path, required=True)
    parser.add_argument("--lexique", type=Path, required=True)
    parser.add_argument("--root", type=Path, default=Path("."))
    args = parser.parse_args()

    root = args.root
    user = root / "user-data"
    corpus = args.corpus
    chinese_names = read_lines(corpus / "Chinese_Names_Corpus/Chinese_Names_Corpus（120W）.txt")
    translated_names = read_lines(corpus / "English_Names_Corpus/English_Cn_Name_Corpus（48W）.txt")
    chinese_names |= {name for name in translated_names if len(name) >= 3}
    chinese_names |= CHINESE_SHORT_TRANSLITERATIONS | CHINESE_EXTRA_NAMES
    chinese_words = set().union(*(dictionary_words(user / "cn_dicts" / f"{name}.dict.yaml")
                                  for name in ("base", "ext", "tencent", "others")))
    chinese_common = cedict_common_words(root / "sources/cedict/cedict_ts.u8")
    chinese = {word for word in chinese_names & chinese_words
               if 2 <= len(word) <= 8 and (word not in chinese_common or word in CHINESE_EXTRA_NAMES)
               and word not in CHINESE_NON_NAMES
               and re.fullmatch(r"[\u4e00-\u9fff]+", word)}

    english_names = {word.lower() for word in read_lines(corpus / "English_Names_Corpus/English_Names_Corpus（2W）.txt")}
    english_words = set().union(*(dictionary_words(user / "en_dicts" / f"{name}.dict.yaml")
                                  for name in ("en", "en_ext", "dev")))
    english = {word for word in english_words if word.istitle() and word.isascii()
               and word.lower() in english_names and word not in ENGLISH_NON_NAMES}

    french_names = {line.split("\t", 1)[0] for line in
                    (root / "sources/person_names/fr_insee_2024_names.tsv").read_text(encoding="utf-8").splitlines()
                    if line and not line.startswith("#")}
    french_words = dictionary_words(user / "fr.dict.yaml")
    french_common = french_common_words(args.lexique)
    french = {word for word in french_words if word.lower() in french_names
              and (word.lower() not in french_common or word.lower() in FRENCH_NAMES_WITH_COMMON_SPELLINGS)
              and word.lower() not in FRENCH_NON_NAMES}

    output = user / "others/person_names.txt"
    lines = ["# 人名候选降序索引。普通词同形时优先保留普通词。\n",
             "# 中文、英文：wainshine/Chinese-Names-Corpus (Apache-2.0, commit 47d4af8)。\n",
             "# 法语：INSEE Base prénoms 2024 (Licence Ouverte v2.0)。\n",
             "# 排除普通词：CC-CEDICT (CC BY-SA 3.0)、Lexique 3.83 (CC BY-SA 4.0)。\n"]
    for lang, words in (("cn", chinese), ("en", english), ("fr", french)):
        lines.extend(f"{lang}\t{word}\n" for word in sorted(words))
    output.write_text("".join(lines), encoding="utf-8")
    print(f"{output}: cn={len(chinese)} en={len(english)} fr={len(french)}")


if __name__ == "__main__":
    main()
