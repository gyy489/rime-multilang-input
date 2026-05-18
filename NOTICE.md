# Third-Party Notices

This project is a macOS Rime configuration distribution built on top of several open-source projects and open lexical datasets.

The repository-level license is GPL-3.0-only because the distributed configuration includes and derives from GPL-licensed Rime configuration/application components. Individual third-party files keep their original licenses.

## Upstream Components

| Component | Use in this project | License / Notice |
| --- | --- | --- |
| Rime / librime | Input method engine used by Squirrel | BSD-3-Clause |
| Squirrel | macOS Rime front end | GPL-3.0 |
| rime-ice | Base Chinese schema and dictionaries | GPL-3.0-only |
| ECDICT | English-to-Chinese translation comments | MIT |
| CC-CEDICT | Chinese-to-English translation comments | CC BY-SA 4.0 |
| FrequencyWords | French frequency dictionary source | Code: MIT; content: CC BY-SA 4.0 |
| THUOCL | IT / programming Chinese dictionary | MIT; upstream also asks users to cite THUOCL in academic use |

## Source Links

- Rime / librime: https://github.com/rime/librime
- Squirrel: https://github.com/rime/squirrel
- rime-ice: https://github.com/iDvel/rime-ice
- ECDICT: https://github.com/skywind3000/ECDICT
- CC-CEDICT: https://www.mdbg.net/chinese/dictionary?page=cc-cedict
- FrequencyWords: https://github.com/hermitdave/FrequencyWords
- THUOCL: https://github.com/thunlp/THUOCL

## Distribution Notes

Generated dictionaries derived from CC BY-SA 4.0 sources should preserve attribution and be redistributed under compatible ShareAlike terms. GPL-covered components must keep their license notices, and source form should remain available to recipients when distributing modified versions.
