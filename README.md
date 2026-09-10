# Rime 中英法混合输入（macOS）

基于 [Rime](https://rime.im/)、[鼠须管 Squirrel](https://github.com/rime/squirrel) 和[雾凇拼音](https://github.com/iDvel/rime-ice) 的 macOS 输入配置，面向中英法混合写作与代码输入。

在 Rime 的中文模式下，中文、英文和法语候选会出现在同一个候选窗；中英文候选还可显示简短的离线翻译注释。

## 特性

- 中英法混合候选：中文使用雾凇拼音，英文使用 `melt_eng`，法语使用 50k 频率词表。
- 分语言拼写容错：中文只保留平翘舌轻量模糊音，法语使用少量容错，英文支持更丰富的常见拼写纠错。
- 离线翻译注释：英文候选显示短中文释义，中文词组显示短英文释义。
- 编程词库：内置 THUOCL IT 中文词库与常用英文开发术语。
- 英文输入学习：记录回车提交的英文词频，逐步优化同码候选排序。
- 代码友好标点：默认使用美式符号，短按左右 `Shift` 可切换中文符号层。
- 可迁移配置：可将 `~/Library/Rime` 链接到仓库的 `user-data/`，方便换机或同步。

## 快速安装

适用于 macOS。安装脚本会下载并安装鼠须管及所需词库，已有的 `~/Library/Rime` 会先按时间戳备份。

```sh
curl -fsSL \
  https://raw.githubusercontent.com/gyy489/rime-multilang-input/main/scripts/online_install_from_readme.sh \
  -o /tmp/install-rime-multilang.sh
bash /tmp/install-rime-multilang.sh
```

默认安装到 `$HOME/Rime输入法`。如需指定目录：

```sh
RIME_PORTABLE_DIR="$HOME/Documents/Rime输入法" \
  bash /tmp/install-rime-multilang.sh
```

脚本需要联网，并使用 macOS 自带的 `curl`、`python3`、`pkgutil`、`ditto` 和 `unzip`。如缺少 `git`，先运行 `xcode-select --install`。

安装结束后退出当前 macOS 用户并重新登录，再到 `系统设置 → 键盘 → 输入法` 添加“简体中文 → 鼠须管”。

## 使用已有仓库

已克隆仓库或需要迁移完整配置时，先安装[鼠须管](https://github.com/rime/squirrel/releases)，再将 Rime 用户目录链接到仓库：

```sh
cd /path/to/rime-multilang-input
BASE="$PWD"

if [ -e "$HOME/Library/Rime" ] || [ -L "$HOME/Library/Rime" ]; then
  mv "$HOME/Library/Rime" "$HOME/Library/Rime.backup.$(date +%Y%m%d-%H%M%S)"
fi
ln -s "$BASE/user-data" "$HOME/Library/Rime"

"$BASE/scripts/reload_and_select_squirrel.sh" --build
```

如果配置位于外置盘、NAS 或其他登录后才挂载的位置，可安装登录自动重载：

```sh
"$BASE/scripts/install_squirrel_login_reload_agent.sh"
```

卸载自动重载：

```sh
"$BASE/scripts/install_squirrel_login_reload_agent.sh" --uninstall
```

## 使用说明

保持 Rime 在“中”模式即可混合输入：

- `nihao`：中文候选。
- `hello`：英文候选，并显示简短中文释义。
- `francais`：法语候选 `français`，带 `〔FR〕` 标记。
- `F4`：打开方案与选项菜单；需要纯英文时可在这里切换，或使用 macOS 的 ABC 输入法。

### 标点切换

默认是美式符号层，适合代码输入。短按左或右 `Shift` 切换中文符号层，再短按一次切回；`Control+Shift+3` 是备用切换键。长按 `Shift` 与其他键组合时仍用于大写和上档符号。

| 操作 | 美式符号层 | 中文符号层 |
| --- | --- | --- |
| `Shift+,` / `Shift+.` | `<` / `>` | `《` / `》` |
| `Shift+[` / `Shift+]` | `{` / `}` | `「` / `」` |
| `Shift+'` | `"` | `“”` |
| `` Shift+` `` | `~` | `～` |

68 键键盘若由 `Esc` 复用反引号键，可用 `Fn+Shift+Esc` 输入波浪号。短按阈值可在 `user-data/rime_ice.custom.yaml` 的 `shift_punct_toggle/tap_threshold_ms` 中调整。

### 翻译与英文学习

- 翻译注释完全离线；设置 `translation_comment/enabled: false` 可关闭。
- 空格选择英文候选时，`melt_eng` 会使用 Rime 用户词频学习。
- 回车提交纯英文时，词频记录在本机生成的 `user-data/english_learning.tsv` 中。

## 维护

修改配置或词库后重新部署：

```sh
cd /path/to/rime-multilang-input
./scripts/reload_and_select_squirrel.sh --build
```

如果输入法可见但没有候选窗，可直接运行：

```sh
./scripts/reload_and_select_squirrel.sh
```

脚本默认查找 `~/Library/Input Methods/Squirrel.app` 和 `/Library/Input Methods/Squirrel.app`。可通过 `RIME_USER_DIR` 指定其他 Rime 用户目录。

### 同步与隐私

适合同步的内容是配置、词库和脚本。以下文件包含本机状态或个人学习数据，已由 `.gitignore` 排除，不应提交到公共仓库：

- `user-data/*.userdb/`
- `user-data/english_learning.tsv`
- `user-data/user.yaml`
- `user-data/installation.yaml`
- `user-data/build/`

跨电脑同步个人词频时，避免两台机器同时写入同一份 `*.userdb/`。

## 目录结构

| 路径 | 用途 |
| --- | --- |
| `user-data/` | Rime 方案、词库、Lua 扩展和鼠须管主题 |
| `scripts/online_install_from_readme.sh` | 从上游重建完整配置的一键安装脚本 |
| `scripts/reload_and_select_squirrel.sh` | 构建、重载并选择鼠须管输入源 |
| `scripts/install_squirrel_login_reload_agent.sh` | 为延迟挂载目录安装登录自动重载 |
| `scripts/build_*.py` | 生成法语、编程与翻译词库 |
| `sources/` | 词典来源与构建输入 |

## 许可证与来源

项目按 [GPL-3.0-only](LICENSE) 发布。第三方组件、词典来源和各自许可证见 [NOTICE.md](NOTICE.md)。主要上游包括：

- [Rime / librime](https://github.com/rime/librime)
- [Squirrel](https://github.com/rime/squirrel)
- [rime-ice](https://github.com/iDvel/rime-ice)
- [THUOCL](https://github.com/thunlp/THUOCL)
- [FrequencyWords](https://github.com/hermitdave/FrequencyWords)
- [ECDICT](https://github.com/skywind3000/ECDICT)
- [CC-CEDICT](https://www.mdbg.net/chinese/dictionary?page=cc-cedict)
