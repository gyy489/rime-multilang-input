# macOS Rime 中英法输入配置

这是一套基于 Rime / 鼠须管 Squirrel / 雾凇拼音 rime-ice 的 macOS 输入法配置。它不是从零重写的新输入法引擎，而是在成熟开源输入法的基础上，整理出一个面向中英法三语写作、代码写作和可迁移使用的配置发行版。

目标很朴素：日常主要输入中文和英文，需要时也能直接输入法语；候选窗里可以混合显示中文、英文、法语，并给中英候选附上简短离线翻译提示。

## 项目注意事项与写作标准

- 这是 Rime / 鼠须管配置发行版，不是新的输入法内核；优先通过 `user-data/*.custom.yaml`、`user-data/lua/`、词库和安装脚本扩展行为。
- 日常混输保持在 Rime 的“中”模式：中文、英文、法语候选都在同一个候选窗里；需要纯英文模式时用 `F4` 切换，或直接切到 macOS 的 ABC 输入法。
- 符号层默认是美式键盘标准。单击左/右 Shift 切换中/英符号层；长按 Shift 仍用于大写和上档输入。不依赖外部改键软件。
- 键盘兼容目标是 MacBook 原装键盘和 68 键外接键盘同时可用：MacBook 用 `` Shift+` `` 输入 `~`，68 键键盘用 `Fn+Shift+Esc` 输入 `~`。
- 个人学习数据适合同步到自己的电脑，但不适合公开提交：`user-data/*.userdb/`、`user-data/english_learning.tsv`、`user-data/user.yaml`、`user-data/installation.yaml`、`user-data/build/` 应保持私有或由本机生成。
- 每次改输入行为，都同步更新根目录 `README.md` 和“只有 README 时在线安装”脚本；文档要写清楚默认状态、切换键、示例输出、依赖项和复刻命令。
- 迁移说明要使用可替换的 `BASE` 路径，不写死某台电脑的目录；新增脚本要能从脚本自身位置推导项目根目录。
- 对外发布前保留 `LICENSE`、`NOTICE.md` 和上游来源说明；涉及个人习惯、安装包、本地应用和生成缓存的内容不要进公开仓库。

## 已实现功能

- 中英法混合候选：中文基于雾凇拼音，英文基于 `melt_eng`，法语基于 50k 频率词表。
- 离线中英互译注释：英文候选显示短中文释义，中文词组显示短英文释义。
- 编程词库：加入 THUOCL IT 中文词库和一批常用英文开发术语。
- 英文回车学习：回车提交纯英文输入时记录词频，之后同码英文候选会按使用习惯前移。
- 标点层可切换：默认是美式符号层；单击左/右 Shift 或 `Control+Shift+3` 切换中/英符号层，68 键外接键盘支持 `Fn+Shift+Esc` 输出波浪号。
- 双键盘适配：MacBook 原装键盘和 68 键外接键盘都按同一套中/英符号层规则工作。
- 系统配色高亮：鼠须管主题显式使用当前 macOS 选中背景色，避免候选高亮经过内置主题偏色。
- 可迁移与同步：`~/Library/Rime` 链接到本文件夹的 `user-data/`，配置、词库、用户词频和状态文件都可以跟着这个文件夹走。
- README 在线安装：新电脑即使只有这份 README，也可以用脚本联网重建同一套配置。

## 暑假开发计划

后续可以把这套配置继续发展成一个正式开源项目。比较适合逐步推进的方向：

- 优化候选排序：让中文、英文、法语和编程词在同一个输入串下更自然地排序。
- 改进翻译注释：继续压缩释义长度，给高频词和代码词补更准确的人工覆盖。
- 增加领域词库：为写代码、论文、法语学习、产品文档等场景提供可选词库。
- 做配置开关：把翻译注释、法语候选、编程词库、主题等做成更容易切换的配置。
- 整理安装器：把现在的 README 脚本拆成更清晰的安装、更新、备份、迁移命令。
- 补充测试/检查：为词库生成脚本、Lua 过滤器和 YAML 配置增加基础校验。

## 目录结构

这个文件夹把 Rime 的可迁移部分集中放在外置盘：

- `user-data/`: Rime 用户目录。中文、英文、法语方案和之后的用户词频都会在这里。
- `installers/Squirrel-1.1.2.pkg`: 官方鼠须管安装包备份。
- `apps/Squirrel.app`: 从官方安装包解出的应用备份。
- `sources/rime-ice/`: 雾凇拼音源码备份。
- `sources/frequencywords/fr_50k.txt`: 法语 50k 频率词表来源。
- `sources/thuocl/THUOCL_IT.txt`: 清华 THUOCL IT 词表来源。
- `scripts/build_french_rime_dict.py`: 重新生成 `user-data/fr.dict.yaml` 的脚本。
- `scripts/build_thuocl_it_rime_dict.py`: 重新生成 `user-data/cn_dicts/thuocl_it.dict.yaml` 的脚本。
- `scripts/reload_and_select_squirrel.sh`: 重载并选择鼠须管输入源的脚本。

## 复刻速记

在任意新 Mac 上复刻这套输入法有两种方式：

- 只有 README：走下面的“只有 README 时在线安装”，会联网下载上游项目并生成一套干净的新配置。
- 有完整文件夹：走“带着整个文件夹迁移安装”，把 `~/Library/Rime` 链接到这个文件夹的 `user-data/`。
- 要切换中/英符号层：单击左/右 Shift；备用键是 Rime 内置的 `Control+Shift+3`。
- 要同步个人习惯：同步 `user-data/rime_ice.userdb/` 和 `user-data/english_learning.tsv`，另一台电脑会继承中文候选学习和英文回车学习。
- 要公开开源：不要提交 `user-data/*.userdb/`、`user-data/english_learning.tsv`、`user-data/user.yaml`、`user-data/installation.yaml` 和 `user-data/build/`。

## 键位行为速记

当前目标是写代码友好：默认是美式符号层，需要中文标点时临时切换。

| 操作 | 美式符号层 | 中文符号层 |
| --- | --- | --- |
| 单击左/右 Shift | 切到中文符号层 | 切回美式符号层 |
| `Control+Shift+3` | 切到中文符号层 | 切回美式符号层 |
| `Shift+,` / `Shift+.` | `<` / `>` | `《` / `》` |
| `Shift+[` / `Shift+]` | `{` / `}` | `「` / `」` |
| `Shift+'` | `"` | `“”` |
| `Shift+\`` | `~` | `～` |
| 68 键键盘 `Fn+Shift+Esc` | `~` | `～` |

这里有三个容易混淆的波浪号：

- `~`: ASCII tilde，代码、终端和配置文件用这个。
- `～`: 全角波浪号，中文符号层输出这个。
- `˜`: small tilde，常由 macOS 重音死键生成，不适合当作代码里的波浪号。

## 只有 README 时在线安装

如果新电脑访问不到这个盘、手上只有这份 README，也可以从互联网重新搭出同一套输入法。下面脚本会下载官方鼠须管、雾凇拼音、法语词表、英汉/中英离线词典，并生成当前这套中英法混输、系统配色高亮、翻译注释、可切换中英符号层、英文回车学习配置。

注意：这种方式会生成一套干净配置，不会包含你在旧电脑上的候选学习历史。要带走个人词频习惯，请同步完整 `user-data/`，或至少同步 `*.userdb/` 和 `english_learning.tsv`。

默认安装目录是：

```sh
$HOME/Rime输入法
```

如果你想换目录，可以在运行前设置 `RIME_PORTABLE_DIR`，例如：

```sh
export RIME_PORTABLE_DIR="$HOME/Documents/Rime输入法"
```

新电脑需要联网，并且需要 macOS 自带的 `curl`、`python3`、`pkgutil`、`ditto`、`unzip`。如果没有 `git`，先运行：

```sh
xcode-select --install
```

然后复制下面整段到 Terminal 运行：

<details>
<summary>在线安装脚本</summary>

```sh
cat > /tmp/install_rime_multilang.sh <<'INSTALL_RIME'
#!/usr/bin/env bash
set -euo pipefail

BASE="${RIME_PORTABLE_DIR:-$HOME/Rime输入法}"
MACOS_VERSION="$(sw_vers -productVersion)"
MACOS_MAJOR="${MACOS_VERSION%%.*}"

if [ "${MACOS_MAJOR}" -ge 13 ]; then
  SQUIRREL_VERSION="1.1.2"
  SQUIRREL_ARCHIVE="Squirrel-${SQUIRREL_VERSION}.pkg"
else
  SQUIRREL_VERSION="0.16.2"
  SQUIRREL_ARCHIVE="Squirrel-${SQUIRREL_VERSION}.zip"
fi

need() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing command: $1" >&2
    return 1
  fi
}

need curl
need python3
need pkgutil
need tar
need ditto
need unzip
if ! command -v git >/dev/null 2>&1; then
  echo "git is required. Run: xcode-select --install" >&2
  exit 1
fi

mkdir -p "$BASE"/{installers,apps,sources,user-data,scripts}

echo "==> Download Squirrel ${SQUIRREL_VERSION} for macOS ${MACOS_VERSION}"
curl -L --fail \
  -o "$BASE/installers/$SQUIRREL_ARCHIVE" \
  "https://github.com/rime/squirrel/releases/download/${SQUIRREL_VERSION}/${SQUIRREL_ARCHIVE}"

echo "==> Extract and install Squirrel.app"
rm -rf "$BASE/.tmp-squirrel"
mkdir -p "$BASE/.tmp-squirrel/app"
if [[ "$SQUIRREL_ARCHIVE" == *.zip ]]; then
  unzip -q "$BASE/installers/$SQUIRREL_ARCHIVE" -d "$BASE/.tmp-squirrel"
  SQUIRREL_PKG_PATH="$BASE/.tmp-squirrel/Squirrel.pkg"
else
  SQUIRREL_PKG_PATH="$BASE/installers/$SQUIRREL_ARCHIVE"
fi

echo "==> Run official Squirrel installer"
sudo installer -pkg "$SQUIRREL_PKG_PATH" -target /

pkgutil --expand "$SQUIRREL_PKG_PATH" "$BASE/.tmp-squirrel/pkg"
tar -xzf "$BASE/.tmp-squirrel/pkg/Payload" -C "$BASE/.tmp-squirrel/app" ./Squirrel.app
ditto "$BASE/.tmp-squirrel/app/Squirrel.app" "$BASE/apps/Squirrel.app"

SQUIRREL_APP="/Library/Input Methods/Squirrel.app"
if [ ! -d "$SQUIRREL_APP" ]; then
  SQUIRREL_APP="$HOME/Library/Input Methods/Squirrel.app"
fi

echo "==> Download rime-ice"
if [ -d "$BASE/sources/rime-ice/.git" ]; then
  git -C "$BASE/sources/rime-ice" pull --ff-only
else
  git clone --depth 1 https://github.com/iDvel/rime-ice.git "$BASE/sources/rime-ice"
fi
rsync -a --delete --exclude='.git' "$BASE/sources/rime-ice/" "$BASE/user-data/"

python3 - "$BASE/user-data/rime_ice.dict.yaml" <<'PY'
from pathlib import Path
path = Path(__import__('sys').argv[1])
text = path.read_text(encoding='utf-8')
line = '  - cn_dicts/thuocl_it # IT / 编程词库\n'
if line not in text:
    marker = '  # - cn_dicts/41448  # 大字表（按需启用）（启用时和 8105 同时启用并放在 8105 下面）\n'
    text = text.replace(marker, marker + line, 1)
path.write_text(text, encoding='utf-8')
PY

python3 - "$BASE/user-data/melt_eng.dict.yaml" <<'PY'
from pathlib import Path
path = Path(__import__('sys').argv[1])
text = path.read_text(encoding='utf-8')
line = '  - en_dicts/dev    # 编程 / 开发英文术语\n'
if line not in text:
    marker = 'import_tables:\n'
    text = text.replace(marker, marker + line, 1)
path.write_text(text, encoding='utf-8')
PY

mkdir -p "$BASE/user-data/en_dicts"
cat > "$BASE/user-data/en_dicts/dev.dict.yaml" <<'YAML'
# Rime dictionary
# encoding: utf-8
#
# Developer English terms for mixed coding input.

---
name: dev
version: "2026-05-16"
sort: by_weight
columns:
  - text
  - code
  - weight
...
API	API	1000
SDK	SDK	1000
CLI	CLI	1000
GUI	GUI	900
TUI	TUI	700
IDE	IDE	1000
REPL	REPL	800
URI	URI	800
URL	URL	1000
HTTP	HTTP	1000
HTTPS	HTTPS	1000
JSON	JSON	1000
JSONL	JSONL	700
YAML	YAML	1000
TOML	TOML	800
XML	XML	900
CSV	CSV	900
HTML	HTML	1000
CSS	CSS	1000
JavaScript	JavaScript	1000
TypeScript	TypeScript	1000
JS	JS	1000
JSX	JSX	900
TS	TS	900
TSX	TSX	900
SQL	SQL	1000
NoSQL	NoSQL	900
GraphQL	GraphQL	1000
REST	REST	1000
RESTful	RESTful	900
gRPC	gRPC	900
WebSocket	WebSocket	900
OAuth	OAuth	900
JWT	JWT	900
CORS	CORS	900
CDN	CDN	900
DNS	DNS	900
TCP	TCP	900
UDP	UDP	900
TLS	TLS	900
SSL	SSL	800
SSH	SSH	1000
SFTP	SFTP	700
SMTP	SMTP	700
IMAP	IMAP	700
OpenAPI	OpenAPI	900
Swagger	Swagger	800
Postman	Postman	800
cURL	cURL	800
Docker	Docker	1000
Dockerfile	Dockerfile	1000
Docker Compose	DockerCompose	900
Kubernetes	Kubernetes	1000
K8s	K8s	1000
Helm	Helm	800
Terraform	Terraform	800
Ansible	Ansible	700
Nginx	Nginx	900
Redis	Redis	900
PostgreSQL	PostgreSQL	900
Postgres	Postgres	900
MySQL	MySQL	900
SQLite	SQLite	900
MongoDB	MongoDB	900
Elasticsearch	Elasticsearch	800
Kafka	Kafka	800
RabbitMQ	RabbitMQ	700
React	React	1000
React Native	ReactNative	900
Vue	Vue	1000
Vue.js	Vue.js	1000
Angular	Angular	800
Svelte	Svelte	800
Next.js	Next.js	1000
Nuxt	Nuxt	800
Vite	Vite	900
Webpack	Webpack	900
Rollup	Rollup	700
Babel	Babel	800
ESLint	ESLint	800
Prettier	Prettier	800
Tailwind CSS	TailwindCSS	900
Node.js	Node.js	1000
npm	npm	1000
pnpm	pnpm	900
yarn	yarn	800
Bun	Bun	800
Deno	Deno	800
Python	Python	1000
Java	Java	1000
Kotlin	Kotlin	800
Swift	Swift	800
Rust	Rust	900
Go	Go	900
Golang	Golang	900
Ruby	Ruby	700
PHP	PHP	800
Lua	Lua	700
Bash	Bash	900
Zsh	Zsh	800
PowerShell	PowerShell	800
C++	C++	900
C#	C#	900
Objective-C	Objective-C	700
FastAPI	FastAPI	800
Django	Django	800
Flask	Flask	800
Express	Express	800
NestJS	NestJS	800
Spring Boot	SpringBoot	800
SQLAlchemy	SQLAlchemy	700
Git	Git	1000
GitHub	GitHub	1000
GitLab	GitLab	900
Bitbucket	Bitbucket	700
commit	commit	1000
rebase	rebase	900
merge	merge	900
branch	branch	900
stash	stash	800
cherry-pick	cherry-pick	700
pull request	pullrequest	1000
code review	codereview	900
CI	CI	900
CD	CD	800
CI/CD	CICD	900
GitHub Actions	GitHubActions	900
Jenkins	Jenkins	700
CircleCI	CircleCI	700
Travis CI	TravisCI	700
frontend	frontend	1000
backend	backend	1000
full-stack	fullstack	800
middleware	middleware	1000
microservice	microservice	900
monorepo	monorepo	900
polyrepo	polyrepo	700
callback	callback	1000
promise	promise	900
async	async	1000
await	await	1000
coroutine	coroutine	800
generator	generator	700
iterator	iterator	800
observable	observable	700
stream	stream	800
buffer	buffer	800
cache	cache	900
caching	caching	800
memoization	memoization	700
debounce	debounce	800
throttle	throttle	800
regex	regex	1000
regexp	regexp	900
regular expression	regularexpression	900
serialization	serialization	800
deserialization	deserialization	800
idempotent	idempotent	700
concurrency	concurrency	900
parallelism	parallelism	800
thread	thread	900
process	process	800
mutex	mutex	800
semaphore	semaphore	700
deadlock	deadlock	800
race condition	racecondition	800
event loop	eventloop	900
garbage collection	garbagecollection	800
heap	heap	800
stack	stack	800
pointer	pointer	800
reference	reference	800
closure	closure	900
lambda	lambda	800
recursion	recursion	800
dynamic programming	dynamicprogramming	800
binary search	binarysearch	800
hash map	hashmap	800
linked list	linkedlist	800
tree	tree	700
trie	trie	700
graph	graph	700
queue	queue	800
object	object	800
class	class	900
interface	interface	900
enum	enum	800
struct	struct	800
generic	generic	800
template	template	800
namespace	namespace	800
module	module	900
package	package	900
dependency	dependency	900
dev dependency	devdependency	800
lockfile	lockfile	800
semver	semver	800
versioning	versioning	700
release	release	800
changelog	changelog	800
migration	migration	800
schema	schema	900
database	database	1000
index	index	800
query	query	900
transaction	transaction	800
ACID	ACID	700
CRUD	CRUD	800
ORM	ORM	800
endpoint	endpoint	900
webhook	webhook	800
payload	payload	900
request	request	900
response	response	900
header	header	800
cookie	cookie	800
session	session	800
token	token	800
authentication	authentication	800
authorization	authorization	800
encryption	encryption	800
hashing	hashing	800
salt	salt	700
secret	secret	800
environment variable	environmentvariable	800
dotenv	dotenv	700
localhost	localhost	900
feature flag	featureflag	800
bug	bug	900
hotfix	hotfix	800
regression	regression	800
unit test	unittest	900
integration test	integrationtest	900
E2E test	E2Etest	900
snapshot test	snapshottest	700
mock	mock	800
stub	stub	700
fixture	fixture	700
lint	lint	800
format	format	800
build	build	900
deploy	deploy	900
rollback	rollback	800
staging	staging	800
production	production	800
development	development	800
sandbox	sandbox	800
observability	observability	700
logging	logging	800
metrics	metrics	800
tracing	tracing	800
alerting	alerting	700
YAML

cat > "$BASE/user-data/default.custom.yaml" <<'YAML'
# Rime patch
# encoding: utf-8

patch:
  schema_list:
    - schema: rime_ice
  menu/page_size: 9
  ascii_composer/switch_key/Shift_L: noop
  ascii_composer/switch_key/Shift_R: noop
YAML

cat > "$BASE/user-data/rime_ice.custom.yaml" <<'YAML'
# Rime patch
# encoding: utf-8

patch:
  schema/dependencies:
    - melt_eng
    - radical_pinyin
    - fr

  # 默认使用美式键盘标点；单击 Shift 或 Control+Shift+3 切换中/英符号层。
  switches/@1/reset: 1

  engine/processors:
    - lua_processor@*shift_punct_toggle
    - lua_processor@*select_character
    - ascii_composer
    - recognizer
    - key_binder
    - lua_processor@*mac_punctuation
    - lua_processor@*code_punctuation
    - speller
    - punctuator
    - selector
    - navigator
    - lua_processor@*english_learning_processor
    - express_editor

  engine/translators:
    - punct_translator
    - script_translator
    - lua_translator@*date_translator
    - lua_translator@*lunar
    - lua_translator@*uuid
    - table_translator@custom_phrase
    - table_translator@melt_eng
    - table_translator@french
    - table_translator@cn_en
    - table_translator@radical_lookup
    - lua_translator@*unicode
    - lua_translator@*number_translator
    - lua_translator@*calc_translator
    - lua_translator@*force_gc

  engine/filters:
    - lua_filter@*corrector
    - reverse_lookup_filter@radical_reverse_lookup
    - lua_filter@*autocap_filter
    - lua_filter@*v_filter
    - lua_filter@*pin_cand_filter
    - lua_filter@*long_word_filter
    - lua_filter@*reduce_english_filter
    - lua_filter@*english_learning_filter
    - simplifier@emoji
    - simplifier@traditionalize
    - lua_filter@*search@radical_pinyin
    - lua_filter@*translation_comment
    - uniquifier

  french:
    dictionary: fr
    enable_completion: true
    enable_sentence: false
    enable_user_dict: false
    initial_quality: 0.85
    comment_format:
      - xform/^.+$/〔FR〕/

  melt_eng:
    dictionary: melt_eng
    enable_completion: true
    enable_sentence: false
    enable_user_dict: true
    initial_quality: 1.35
    comment_format:
      - xform/^.+$//

  english_learning:
    scan_limit: 20
    promote_to_first_at: 5

  translation_comment/enabled: true
YAML

cat > "$BASE/user-data/fr.schema.yaml" <<'YAML'
# Rime schema
# encoding: utf-8

schema:
  schema_id: fr
  name: Français
  version: "2026-05-16"
  author:
    - "Generated from hermitdave/FrequencyWords"
  description: |
    French table dictionary for mixed Chinese / English / French input.

switches:
  - name: ascii_mode
    reset: 0
    states: [FR, ASCII]

engine:
  processors:
    - ascii_composer
    - key_binder
    - speller
    - selector
    - navigator
    - express_editor
  segmentors:
    - matcher
    - ascii_segmentor
    - abc_segmentor
    - punct_segmentor
    - fallback_segmentor
  translators:
    - table_translator
  filters:
    - uniquifier

speller:
  alphabet: zyxwvutsrqponmlkjihgfedcbaZYXWVUTSRQPONMLKJIHGFEDCBA
  delimiter: " '"

translator:
  dictionary: fr
  enable_completion: true
  enable_sentence: false
  enable_user_dict: true
  spelling_hints: 0

key_binder:
  import_preset: default

recognizer:
  import_preset: default
YAML

cat > "$BASE/user-data/squirrel.custom.yaml" <<'YAML'
# Squirrel skin patch
# encoding: utf-8

patch:
  config_version: '2026-05-16-system-current'
  style/color_scheme: system_current
  style/color_scheme_dark: system_current
  style/candidate_list_layout: stacked
  style/text_orientation: horizontal
  style/inline_preedit: true
  style/inline_candidate: false
  style/memorize_size: true
  style/translucency: false
  style/mutual_exclusive: true
  style/show_paging: false
  style/corner_radius: 6
  style/hilited_corner_radius: 0
  style/border_height: 0
  style/border_width: 0
  style/line_spacing: 6
  style/spacing: 8
  style/shadow_size: 0
  style/candidate_format: "[label]. [candidate] [comment]"

  preset_color_schemes/system_current:
    name: "System Current"
    author: "Codex"
    color_space: srgb
    alpha: 1
    back_color: 0x1E1E1E
    border_color: 0x1E1E1E
    candidate_back_color: 0x1E1E1E
    preedit_back_color: 0x1E1E1E
    hilited_back_color: 0xD15900
    text_color: 0xFFFFFF
    hilited_text_color: 0xFFFFFF
    candidate_text_color: 0xFFFFFF
    label_color: 0xA0A0A0
    comment_text_color: 0xA0A0A0
    hilited_candidate_back_color: 0xD15900
    hilited_candidate_text_color: 0xFFFFFF
    hilited_candidate_label_color: 0xFFFFFF
    hilited_comment_text_color: 0xFFFFFF
YAML

mkdir -p "$BASE/user-data/lua" "$BASE/user-data/translations"

cat > "$BASE/user-data/lua/shift_punct_toggle.lua" <<'LUA'
local processor = {}

-- Tap Shift to toggle ASCII/Chinese punctuation, while preserving normal
-- Shift chords such as Shift+comma and Shift+letters.
local shift_keys = {
    Shift_L = true,
    Shift_R = true,
}

local function toggle_ascii_punct(context)
    context:set_option("ascii_punct", not context:get_option("ascii_punct"))
end

function processor.func(key, env)
    local context = env.engine.context
    local repr = key:repr():gsub("^Release%+", ""):gsub("^Shift%+", "")

    if key:ctrl() or key:alt() or key:super() then
        return 2
    end

    if shift_keys[repr] then
        if key:release() then
            if env.shift_pending and not env.shift_used then
                toggle_ascii_punct(context)
                env.shift_pending = false
                env.shift_used = false
                return 1
            end
            env.shift_pending = false
            env.shift_used = false
            return 2
        end

        env.shift_pending = true
        env.shift_used = false
        return 2
    end

    if env.shift_pending and key:shift() and not key:release() then
        env.shift_used = true
    end

    return 2
end

return processor
LUA

cat > "$BASE/user-data/lua/mac_punctuation.lua" <<'LUA'
-- macOS Chinese keyboard punctuation.
-- Keep unshifted keys ASCII-friendly, while shifted symbol keys follow the
-- Chinese legends printed on Apple Chinese keyboards.
local processor = {}

local shifted_punctuation = {
    ["1"] = "！",
    ["exclam"] = "！",
    ["2"] = "＠",
    ["at"] = "＠",
    ["3"] = "＃",
    ["numbersign"] = "＃",
    ["4"] = "￥",
    ["dollar"] = "￥",
    ["5"] = "％",
    ["percent"] = "％",
    ["6"] = "……",
    ["asciicircum"] = "……",
    ["7"] = "＆",
    ["ampersand"] = "＆",
    ["8"] = "＊",
    ["asterisk"] = "＊",
    ["9"] = "（",
    ["parenleft"] = "（",
    ["0"] = "）",
    ["parenright"] = "）",
    ["minus"] = "——",
    ["underscore"] = "——",
    ["equal"] = "＋",
    ["plus"] = "＋",
    ["comma"] = "《",
    ["less"] = "《",
    ["period"] = "》",
    ["greater"] = "》",
    ["slash"] = "？",
    ["question"] = "？",
    ["semicolon"] = "：",
    ["colon"] = "：",
    ["bracketleft"] = "「",
    ["braceleft"] = "「",
    ["bracketright"] = "」",
    ["braceright"] = "」",
    ["backslash"] = "｜",
    ["bar"] = "｜",
    ["grave"] = "～",
    ["asciitilde"] = "～",
}

local shifted_pairs = {
    ["apostrophe"] = { "“", "”", "double_quote_close" },
    ["quotedbl"] = { "“", "”", "double_quote_close" },
}

function processor.func(key, env)
    local context = env.engine.context

    if
        key:release()
        or context:get_option("ascii_mode")
        or context:is_composing()
        or context:has_menu()
        or key:ctrl()
        or key:alt()
        or key:super()
    then
        return 2
    end

    local repr = key:repr():gsub("^Shift%+", "")
    if context:get_option("ascii_punct") then
        if repr == "asciitilde" then
            env.engine:commit_text("~")
            return 1
        end
        if repr == "grave" then
            env.engine:commit_text(key:shift() and "~" or "`")
            return 1
        end
        return 2
    end

    local pair = shifted_pairs[repr]
    if pair and key:shift() then
        local state_key = pair[3]
        local text = env[state_key] and pair[2] or pair[1]
        env[state_key] = not env[state_key]
        env.engine:commit_text(text)
        return 1
    end

    local text = shifted_punctuation[repr]
    if text and key:shift() then
        env.engine:commit_text(text)
        return 1
    end

    return 2
end

return processor
LUA

cat > "$BASE/user-data/lua/code_punctuation.lua" <<'LUA'
-- Coding punctuation that would otherwise be consumed by the pinyin speller.
local processor = {}

local quote_pairs = {
    apostrophe = { "‘", "’", "single_quote_close" },
    quotedbl = { "“", "”", "double_quote_close" },
}

function processor.func(key, env)
    local context = env.engine.context

    if
        key:release()
        or context:get_option("ascii_mode")
        or context:is_composing()
        or context:has_menu()
        or key:ctrl()
        or key:alt()
        or key:super()
    then
        return 2
    end

    local repr = key:repr():gsub("^Shift%+", "")
    if repr == "apostrophe" then
        if context:get_option("ascii_punct") then
            env.engine:commit_text(key:shift() and '"' or "'")
        else
            local pair = key:shift() and quote_pairs.quotedbl or quote_pairs.apostrophe
            local state_key = pair[3]
            env.engine:commit_text(env[state_key] and pair[2] or pair[1])
            env[state_key] = not env[state_key]
        end
        return 1
    end
    if repr == "quotedbl" then
        if context:get_option("ascii_punct") then
            env.engine:commit_text('"')
        else
            local pair = quote_pairs.quotedbl
            local state_key = pair[3]
            env.engine:commit_text(env[state_key] and pair[2] or pair[1])
            env[state_key] = not env[state_key]
        end
        return 1
    end

    return 2
end

return processor
LUA

cat > "$BASE/user-data/lua/english_learning_store.lua" <<'LUA'
local M = {
    loaded = false,
    counts = {},
    path = nil,
}

local function trim(text)
    return (text or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

function M.normalize(text)
    local word = trim(text)
    if #word < 2 or not word:match("^[A-Za-z]+$") then
        return nil
    end
    return word:lower()
end

local function sorted_keys(counts)
    local keys = {}
    for key in pairs(counts) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

function M.init()
    if M.loaded then
        return
    end

    local user_data_dir = rime_api:get_user_data_dir()
    M.path = user_data_dir .. "/english_learning.tsv"

    local file = io.open(M.path, "r")
    if file then
        for line in file:lines() do
            local word, count = line:match("^([A-Za-z]+)%t(%d+)$")
            if word and count then
                M.counts[word:lower()] = tonumber(count) or 0
            end
        end
        file:close()
    end

    M.loaded = true
end

function M.save()
    if not M.path then
        return
    end

    local file = io.open(M.path, "w")
    if not file then
        return
    end

    for _, key in ipairs(sorted_keys(M.counts)) do
        local count = M.counts[key]
        if count and count > 0 then
            file:write(key, "\t", tostring(count), "\n")
        end
    end
    file:close()
end

function M.increment(text)
    M.init()

    local key = M.normalize(text)
    if not key then
        return nil
    end

    M.counts[key] = (M.counts[key] or 0) + 1
    M.save()
    return key, M.counts[key]
end

function M.get(text)
    M.init()

    local key = M.normalize(text)
    if not key then
        return 0
    end
    return M.counts[key] or 0
end

return M
LUA

cat > "$BASE/user-data/lua/english_learning_processor.lua" <<'LUA'
local store = require("english_learning_store")

local processor = {}

function processor.init()
    store.init()
end

function processor.func(key, env)
    local context = env.engine.context
    local repr = key:repr()

    if
        key:release()
        or key:ctrl()
        or key:alt()
        or key:super()
        or (repr ~= "Return" and repr ~= "KP_Enter")
        or not context:is_composing()
    then
        return 2
    end

    local raw_input = context.input
    if not store.normalize(raw_input) then
        return 2
    end

    store.increment(raw_input)
    env.engine:commit_text(raw_input)
    context:clear()
    context.commit_history:push("english_learning", raw_input)
    return 1
end

return processor
LUA

cat > "$BASE/user-data/lua/english_learning_filter.lua" <<'LUA'
local store = require("english_learning_store")

local M = {}

local function pass_all(input)
    for cand in input:iter() do
        yield(cand)
    end
end

local function is_exact_english(cand, key)
    return cand.text and cand.text:lower() == key and cand.text:match("^[A-Za-z]+$")
end

function M.init(env)
    store.init()

    local config = env.engine.schema.config
    M.scan_limit = config:get_int("english_learning/scan_limit") or 20
    M.promote_to_first_at = config:get_int("english_learning/promote_to_first_at") or 5
end

function M.func(input, env)
    local key = store.normalize(env.engine.context.input)
    if not key then
        pass_all(input)
        return
    end

    local count = store.get(key)
    if count <= 0 then
        pass_all(input)
        return
    end

    local head = {}
    local tail = {}
    for cand in input:iter() do
        if #head < M.scan_limit then
            table.insert(head, cand)
        else
            table.insert(tail, cand)
        end
    end

    local english_index = nil
    for i, cand in ipairs(head) do
        if is_exact_english(cand, key) then
            english_index = i
            break
        end
    end

    if english_index then
        local english_cand = table.remove(head, english_index)
        local target = count >= M.promote_to_first_at and 1 or 2
        if target > #head + 1 then
            target = #head + 1
        end
        table.insert(head, target, english_cand)
    end

    for _, cand in ipairs(head) do
        yield(cand)
    end

    for _, cand in ipairs(tail) do
        yield(cand)
    end
end

return M
LUA

cat > "$BASE/user-data/lua/translation_comment.lua" <<'LUA'
local M = {}

local function read_tsv(path)
    local map = {}
    local file = io.open(path, "r")
    if not file then
        return map
    end

    for line in file:lines() do
        local key, value = line:match("^(.-)\t(.+)$")
        if key and value and key ~= "" and value ~= "" then
            map[key] = value
        end
    end
    file:close()
    return map
end

local function has_cjk(text)
    return text:find("[\228-\233]") ~= nil
end

local function is_single_cjk_candidate(text)
    return has_cjk(text) and utf8.len(text) == 1
end

local function append_comment(comment, addition)
    comment = comment or ""
    if comment:find(addition, 1, true) then
        return comment
    end
    if comment == "" then
        return addition
    end
    return comment .. " " .. addition
end

function M.init(env)
    local user_data_dir = rime_api:get_user_data_dir()
    M.en_zh = read_tsv(user_data_dir .. "/translations/en_zh.tsv")
    M.zh_en = read_tsv(user_data_dir .. "/translations/zh_en.tsv")

    local config = env.engine.schema.config
    M.enabled = config:get_bool("translation_comment/enabled")
    if M.enabled == nil then
        M.enabled = true
    end
end

function M.func(input)
    if not M.enabled then
        for cand in input:iter() do
            yield(cand)
        end
        return
    end

    for cand in input:iter() do
        local text = cand.text
        local addition = nil

        if text:find("[A-Za-z]") and not has_cjk(text) then
            local translation = M.en_zh[text:lower()]
            if translation then
                addition = "〔" .. translation .. "〕"
            end
        elseif has_cjk(text) and not is_single_cjk_candidate(text) then
            local translation = M.zh_en[text]
            if translation then
                addition = "〔" .. translation .. "〕"
            end
        end

        if addition then
            yield(ShadowCandidate(cand, cand.type, text, append_comment(cand.comment, addition)))
        else
            yield(cand)
        end
    end
end

return M
LUA

cat > "$BASE/user-data/translations/custom.tsv" <<'TSV'
# lang	key	value
# lang: en means English candidate -> Chinese note.
# lang: zh means Chinese candidate -> English note.
en	hello	你好
en	good	好
en	ok	好的
en	yes	是
en	no	不
zh	你好	hello
zh	中文	Chinese
zh	英文	English
zh	输入	input
zh	后来	later
en	API	接口
en	SDK	开发工具包
en	CLI	命令行
en	IDE	集成开发环境
en	JSON	数据格式
en	YAML	配置格式
en	GraphQL	查询语言
en	Docker	容器
en	Kubernetes	容器编排
en	GitHub	代码托管
en	commit	提交
en	rebase	变基
en	merge	合并
en	branch	分支
en	pull request	合并请求
en	code review	代码审查
en	frontend	前端
en	backend	后端
en	middleware	中间件
en	callback	回调
en	async	异步
en	await	等待
en	regex	正则表达式
en	database	数据库
en	endpoint	接口端点
en	payload	载荷
en	request	请求
en	response	响应
en	authentication	认证
en	authorization	授权
en	deploy	部署
en	rollback	回滚
en	staging	预发环境
en	production	生产环境
zh	字符串	string
zh	初始化	initialization
zh	数组	array
zh	编译器	compiler
zh	正则表达式	regex
zh	数据库	database
zh	中间件	middleware
zh	回调	callback
zh	接口	interface
zh	部署	deploy
TSV

echo "==> Download French and dictionary sources"
mkdir -p "$BASE/sources/frequencywords" "$BASE/sources/ecdict" "$BASE/sources/cedict" "$BASE/sources/thuocl"
curl -L --fail -o "$BASE/sources/frequencywords/fr_50k.txt" \
  https://raw.githubusercontent.com/hermitdave/FrequencyWords/master/content/2018/fr/fr_50k.txt
curl -L --fail -o "$BASE/sources/thuocl/THUOCL_IT.txt" \
  https://raw.githubusercontent.com/thunlp/THUOCL/master/data/THUOCL_IT.txt
curl -L --fail -o "$BASE/sources/ecdict/ecdict.csv" \
  https://raw.githubusercontent.com/skywind3000/ECDICT/master/ecdict.csv
curl -L --fail -o "$BASE/sources/cedict/cedict.zip" \
  https://www.mdbg.net/chinese/export/cedict/cedict_1_0_ts_utf-8_mdbg.zip
unzip -o "$BASE/sources/cedict/cedict.zip" -d "$BASE/sources/cedict"

echo "==> Generate THUOCL IT dictionary"
python3 - "$BASE/sources/thuocl/THUOCL_IT.txt" "$BASE/user-data/cn_dicts/thuocl_it.dict.yaml" <<'PY'
import sys
from pathlib import Path

source = Path(sys.argv[1])
output = Path(sys.argv[2])
rows = []
seen = set()
for line in source.read_text(encoding="utf-8").splitlines():
    parts = line.strip().split()
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
with output.open("w", encoding="utf-8", newline="\n") as f:
    f.write("# Rime dictionary\n# encoding: utf-8\n#\n")
    f.write("# IT terms generated from THUOCL.\n")
    f.write("# Source: https://github.com/thunlp/THUOCL\n\n---\n")
    f.write('name: thuocl_it\nversion: "2016-12-24"\n')
    f.write("sort: by_weight\ncolumns:\n  - text\n  - weight\n...\n")
    for word, weight in rows:
        f.write(f"{word}\t{weight}\n")
print(f"wrote {len(rows)} IT terms")
PY

echo "==> Generate French dictionary"
python3 - "$BASE/sources/frequencywords/fr_50k.txt" "$BASE/user-data/fr.dict.yaml" <<'PY'
import re
import sys
import unicodedata
from pathlib import Path

token_re = re.compile(r"^[A-Za-zÀ-ÖØ-öø-ÿŒœÆæ'’.-]+$")
replacements = {"œ": "oe", "Œ": "oe", "æ": "ae", "Æ": "ae"}

def ascii_code(word):
    value = word
    for src, dst in replacements.items():
        value = value.replace(src, dst)
    value = unicodedata.normalize("NFKD", value)
    value = "".join(ch for ch in value if not unicodedata.combining(ch))
    return re.sub(r"[^a-z]", "", value.lower())

source = Path(sys.argv[1])
output = Path(sys.argv[2])
seen = set()
rows = []
for line in source.read_text(encoding="utf-8").splitlines():
    if not line.strip():
        continue
    try:
        word, count_text = line.rsplit(maxsplit=1)
        count = int(count_text)
    except ValueError:
        continue
    if not token_re.match(word):
        continue
    code = ascii_code(word)
    if not code or (word, code) in seen:
        continue
    seen.add((word, code))
    rows.append((word, code, count))

with output.open("w", encoding="utf-8", newline="\n") as f:
    f.write("# Rime dictionary\n# encoding: utf-8\n\n---\n")
    f.write('name: fr\nversion: "2026-05-16"\n')
    f.write("sort: by_weight\nuse_preset_vocabulary: false\n")
    f.write("columns:\n  - text\n  - code\n  - weight\n...\n")
    for word, code, count in rows:
        f.write(f"{word}\t{code}\t{count}\n")
print(f"wrote {len(rows)} French entries")
PY

echo "==> Generate compact translation comments"
python3 - "$BASE/user-data" "$BASE/sources/ecdict/ecdict.csv" "$BASE/sources/cedict/cedict_ts.u8" "$BASE/user-data/translations" <<'PY'
import csv
import re
import sys
from pathlib import Path

chinese_re = re.compile(r"[\u3400-\u9fff]")
cedict_re = re.compile(r"^(\S+)\s+(\S+)\s+\[[^\]]+\]\s+/(.+)/$")
pos_re = re.compile(r"^(?:interj|int|n|v|vi|vt|adj|adv|prep|pron|conj|num|art|aux|abbr|pl|sing|a|erj)\.?\s*", re.I)

def clean_zh(text, max_chars=28):
    text = text.replace("\\n", "\n")
    for line in text.splitlines():
        line = re.sub(r"\[[^\]]+\]", "", line)
        for part in re.split(r"[；;，,]", line):
            part = pos_re.sub("", part.strip(" ，,。:：;；"))
            if chinese_re.search(part):
                return part[: max_chars - 1] + "…" if len(part) > max_chars else part
    return ""

def clean_en(definition, max_chars=24):
    for part in definition.split("/"):
        part = re.sub(r"\([^)]*\)", "", part.strip())
        part = re.sub(r"\[[^\]]*\]", "", part).strip(" ;,")
        low = part.lower()
        if not part or low.startswith(("surname ", "variant of ", "old variant of ", "classifier for ", "cl:")):
            continue
        part = re.split(r"[;,]", part, maxsplit=1)[0].strip()
        if part:
            return part[: max_chars - 1] + "…" if len(part) > max_chars else part
    return ""

def iter_words(path):
    words = set()
    in_body = False
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if line == "...":
            in_body = True
            continue
        if not in_body or not line or line.startswith("#"):
            continue
        words.add(line.split("\t", 1)[0].strip())
    return words

user_data = Path(sys.argv[1])
ecdict = Path(sys.argv[2])
cedict = Path(sys.argv[3])
out_dir = Path(sys.argv[4])
out_dir.mkdir(parents=True, exist_ok=True)

english_words = set()
for path in sorted((user_data / "en_dicts").glob("*.dict.yaml")):
    english_words.update(w.lower() for w in iter_words(path) if re.search(r"[A-Za-z]", w))

chinese_words = set()
for path in list((user_data / "cn_dicts").glob("*.dict.yaml")) + [user_data / "rime_ice.dict.yaml"]:
    if path.exists():
        chinese_words.update(w for w in iter_words(path) if chinese_re.search(w) and len(w) >= 2)

en_rows = {}
with ecdict.open("r", encoding="utf-8", newline="") as f:
    for row in csv.DictReader(f):
        word = (row.get("word") or "").strip().lower()
        if word in english_words and word not in en_rows:
            value = clean_zh(row.get("translation") or "")
            if value:
                en_rows[word] = value

zh_rows = {}
for line in cedict.read_text(encoding="utf-8").splitlines():
    if not line or line.startswith("#"):
        continue
    m = cedict_re.match(line.strip())
    if not m:
        continue
    traditional, simplified, definition = m.groups()
    value = clean_en(definition)
    if not value:
        continue
    for word in (simplified, traditional):
        if word in chinese_words and word not in zh_rows:
            zh_rows[word] = value

custom = out_dir / "custom.tsv"
if custom.exists():
    for raw in custom.read_text(encoding="utf-8").splitlines():
        if not raw.strip() or raw.startswith("#"):
            continue
        parts = raw.split("\t")
        if len(parts) != 3:
            continue
        lang, key, value = parts
        if lang == "en":
            en_rows[key.lower()] = value
        elif lang == "zh":
            zh_rows[key] = value

with (out_dir / "en_zh.tsv").open("w", encoding="utf-8", newline="\n") as f:
    for key in sorted(en_rows):
        f.write(f"{key}\t{en_rows[key]}\n")
with (out_dir / "zh_en.tsv").open("w", encoding="utf-8", newline="\n") as f:
    for key in sorted(zh_rows):
        f.write(f"{key}\t{zh_rows[key]}\n")
print(f"wrote {len(en_rows)} English notes and {len(zh_rows)} Chinese notes")
PY

cat > "$BASE/scripts/reload_and_select_squirrel.sh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

app="$HOME/Library/Input Methods/Squirrel.app"
bin="$app/Contents/MacOS/Squirrel"

open "$app"
"$bin" --reload

swift - <<'SWIFT'
import Carbon
import Foundation

let sourceID = "im.rime.inputmethod.Squirrel.Hans"
let props = [kTISPropertyInputSourceID as String: sourceID] as CFDictionary

guard
  let array = TISCreateInputSourceList(props, false)?.takeRetainedValue() as NSArray?,
  let sources = array as? [TISInputSource],
  let source = sources.first
else {
  fputs("Cannot find input source: \(sourceID)\n", stderr)
  exit(1)
}

let enableStatus = TISEnableInputSource(source)
let selectStatus = TISSelectInputSource(source)

if enableStatus != noErr || selectStatus != noErr {
  fputs("Enable status: \(enableStatus), select status: \(selectStatus)\n", stderr)
  exit(1)
}

print("Selected \(sourceID)")
SWIFT
SH
chmod +x "$BASE/scripts/reload_and_select_squirrel.sh"

echo "==> Link ~/Library/Rime"
if [ -e "$HOME/Library/Rime" ] || [ -L "$HOME/Library/Rime" ]; then
  mv "$HOME/Library/Rime" "$HOME/Library/Rime.backup.$(date +%Y%m%d-%H%M%S)"
fi
ln -s "$BASE/user-data" "$HOME/Library/Rime"

echo "==> Build and reload"
cd "$BASE/user-data"
if ! "$SQUIRREL_APP/Contents/MacOS/Squirrel" --build; then
  echo "Squirrel ${SQUIRREL_VERSION} failed to launch on macOS ${MACOS_VERSION}." >&2
  echo "Try upgrading macOS, or install a different Squirrel release manually." >&2
  exit 1
fi
"$SQUIRREL_APP/Contents/MacOS/Squirrel" --reload
"$BASE/scripts/reload_and_select_squirrel.sh"

echo
echo "Done. Log out and log back in, then add Squirrel in System Settings -> Keyboard -> Input Sources."
echo "Install directory: $BASE"
INSTALL_RIME
bash /tmp/install_rime_multilang.sh
```

</details>

运行完成后退出当前 macOS 用户并重新登录，再到 `系统设置 -> 键盘 -> 输入法` 添加“简体中文 -> 鼠须管”。

脚本固定使用我在本机验证过的鼠须管 `1.1.2`。如果以后要改成更新版本，先查看官方最新发布页： https://github.com/rime/squirrel/releases/latest

## 带着整个文件夹迁移安装

如果新电脑能访问完整的 `Rime输入法` 文件夹，可以走这一节。下面先把这个文件夹路径记到 `BASE`；如果你放在 iCloud、移动硬盘、Dropbox、NAS 或别的目录，只改这一行即可：

```sh
BASE="/Volumes/工程盘-1T/Rime输入法"
```

### 1. 放好文件夹

把整个 `Rime输入法` 文件夹复制或同步到新电脑。建议保持同名；路径不同也没关系，后面的命令只依赖 `BASE`。

### 2. 安装鼠须管

macOS 输入法应用本体必须放在系统会扫描的 Input Methods 目录里，不能只放在外置盘里。推荐安装到当前用户目录：

```sh
mkdir -p "$HOME/Library/Input Methods"
ditto "$BASE/apps/Squirrel.app" "$HOME/Library/Input Methods/Squirrel.app"
```

如果 `apps/Squirrel.app` 不存在，也可以用官方安装包：

```sh
open "$BASE/installers/Squirrel-1.1.2.pkg"
```

安装包会把鼠须管装到系统输入法目录，通常需要管理员密码。

### 3. 连接可迁移用户目录

如果新电脑已有 `~/Library/Rime`，先备份：

```sh
if [ -e "$HOME/Library/Rime" ] || [ -L "$HOME/Library/Rime" ]; then
  mv "$HOME/Library/Rime" "$HOME/Library/Rime.backup.$(date +%Y%m%d-%H%M%S)"
fi
```

然后把 Rime 用户目录链接到这个文件夹：

```sh
ln -s "$BASE/user-data" "$HOME/Library/Rime"
```

### 4. 部署配置

```sh
cd "$BASE/user-data"
"$HOME/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel" --build
"$HOME/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel" --reload
```

### 5. 重新登录并添加输入法

退出当前 macOS 用户并重新登录。然后打开：

```text
系统设置 -> 键盘 -> 输入法
```

添加“简体中文 -> 鼠须管”。如果已经能看到鼠须管但打字不出候选，运行：

```sh
"$BASE/scripts/reload_and_select_squirrel.sh"
```

### 6. 验证

切到鼠须管后，在备忘录或 TextEdit 里测试：

```text
nihao
hello
francais
now
```

应看到中文、英文、法语候选；英文/中文候选会带简短中英互译提示。

## 当前安装状态

鼠须管应用已复制到：

```sh
~/Library/Input Methods/Squirrel.app
```

Rime 用户目录已链接到：

```sh
~/Library/Rime -> /Volumes/工程盘-1T/Rime输入法/user-data
```

所以日后 Rime 生成的用户词典、词频、状态文件会保存在 `user-data/` 里。

## 多电脑同步同款输入法

这套配置的同步边界很清楚：

- 需要同步：`user-data/`，这里保存方案、词库、Lua、主题补丁、构建结果、用户词频和开关状态。
- 可以同步：`scripts/`、`sources/`、`README.md`，方便重建、维护和查说明。
- 每台 Mac 本地安装：`Squirrel.app` 必须放到该机器的 `~/Library/Input Methods/`，不能只依赖另一台机器的安装状态。

### 新电脑首次接入

如果能拿到完整 `Rime输入法` 文件夹，按“带着整个文件夹迁移安装”执行。最关键的是这三步：

```sh
BASE="/Volumes/工程盘-1T/Rime输入法"

mkdir -p "$HOME/Library/Input Methods"
ditto "$BASE/apps/Squirrel.app" "$HOME/Library/Input Methods/Squirrel.app"

if [ -e "$HOME/Library/Rime" ] || [ -L "$HOME/Library/Rime" ]; then
  mv "$HOME/Library/Rime" "$HOME/Library/Rime.backup.$(date +%Y%m%d-%H%M%S)"
fi
ln -s "$BASE/user-data" "$HOME/Library/Rime"

"$BASE/scripts/reload_and_select_squirrel.sh"
```

如果只有 README，没有完整文件夹，就用“只有 README 时在线安装”的脚本在线重建同款配置。

### 日常同步

日常只要同步整个 `Rime输入法` 文件夹，或者至少同步 `user-data/`，另一台电脑重新部署后就是同一套输入法：

```sh
BASE="/Volumes/工程盘-1T/Rime输入法"
cd "$BASE/user-data"
"$HOME/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel" --build
"$HOME/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel" --reload
```

`user-data/rime_ice.userdb/` 是中文候选学习数据，`user-data/english_learning.tsv` 是回车提交英文的学习数据；同步它们以后，另一台电脑也会继承你常用词和候选排序习惯。最好不要在两台电脑同时写同一份 `user-data/` 后再做双向覆盖同步；如果发生冲突，优先保留最近实际使用那台电脑的 `*.userdb/` 和 `english_learning.tsv`。

## 使用方式

1. 退出当前 macOS 用户并重新登录。
2. 打开 `系统设置 -> 键盘 -> 输入法`，如果没有看到鼠须管，就手动添加“简体中文 -> 鼠须管”。
3. 切到鼠须管后，默认方案是“雾凇拼音”。输入候选会混合中文、英文和法语：
   - `nihao` 可以出中文候选。
   - `hello` 可以出英文候选，并带简短中文释义。
   - `francais` 可以出 `français`，法语候选会带 `〔FR〕` 标记。
4. 按 `F4` 可以打开 Rime 方案选单和开关。

中英法混输需要保持在 Rime 的“中”模式。当前已关闭 `Shift` 切换纯英文 ASCII 模式；单击左/右 Shift 用来切换中/英符号层，备用键是 Rime 内置的 `Control+Shift+3`。需要纯英文模式时，可以按 `F4` 在方案选单里切换“中 / Ａ”，或直接切到 macOS 的 ABC 输入法。

## 标点与英文学习

默认是美式符号层；单击左/右 Shift 切到中文符号层，再单击一次切回美式。备用切换键是 `Control+Shift+3`。两个符号层都保留键盘本身的两层结构：不按 `Shift` 是基础层，长按 `Shift` 是上档层。

美式符号层：

- 不按 `Shift`：数字区和符号区按美式键盘直接输入。
- 长按 `Shift`：输入 `! @ # $ % ^ & * ( ) _ + < > { }` 等美式上档符号。
- `Shift+\`` 输出 ASCII 波浪号 `~`；在 68 键外接键盘上，如果 `Esc` 和 `` ` ``/`~` 共用一键，通常用 `Fn+Shift+Esc` 输出 `~`。

中文符号层：

- `Shift+1` / `Shift+2` / `Shift+3` 输出 `！` / `＠` / `＃`。
- `Shift+4` / `Shift+5` / `Shift+6` 输出 `￥` / `％` / `……`。
- `Shift+9` / `Shift+0` 输出 `（` / `）`。
- `Shift+-` / `Shift+=` 输出 `——` / `＋`。
- `Shift+,` / `Shift+.` 输出 `《` / `》`。
- `Shift+[` / `Shift+]` 输出 `「` / `」`。
- `Shift+'` 输出中文双引号 `“”`。
- `Shift+\`` 或 68 键键盘的 `Fn+Shift+Esc` 输出中文全角波浪号 `～`。

`'` 在 Rime 里也可作拼音分隔符，所以这里用 `user-data/lua/code_punctuation.lua` 在没有正在输入拼音时优先上屏单引号。需要大量输入代码符号时，保持美式符号层即可；需要中文书名号、中文括号时，单击 Shift 临时切到中文符号层。

### 轻量切换策略

当前不安装外部改键软件。单击左/右 Shift 由 `user-data/lua/shift_punct_toggle.lua` 切换 Rime 的 `ascii_punct`，用于切换数字键区和符号区的中/英符号层；长按 Shift 仍用于大写和上档符号。

中/英符号层切换统一使用 Rime 原生快捷键：

```text
Shift_L / Shift_R
Control+Shift+3
```

这条配置走 Rime Lua 处理器，不依赖 Karabiner。若某个 macOS / Squirrel 版本无法把纯 Shift 单击交给 Rime，可从 `user-data/rime_ice.custom.yaml` 移除 `lua_processor@*shift_punct_toggle`，回到只用 `Control+Shift+3` 的稳定方案。

纯英文输入的学习规则：

- 空格选择英文候选时，`melt_eng` 会参与 Rime 用户词频学习。
- 回车提交纯英文输入时，会把这个单词计入 `user-data/english_learning.tsv`。
- 同码英文候选会按次数前移；少量使用时通常靠前到第二候选，达到 5 次后可以提升到第一候选。

## 翻译注释

当前启用了本地离线翻译注释：

- 英文候选：`hello 〔你好〕`
- 中文候选：`你好 ［ni hao］ 〔hello〕`

为了避免候选窗太挤，单字中文候选不显示翻译注释；只有两个字及以上的中文词会显示。少数高频词可以在 `user-data/translations/custom.tsv` 里手动覆盖释义，例如 `hello -> 你好`。

相关文件：

- `user-data/lua/translation_comment.lua`: 给候选追加翻译注释的 Lua 过滤器。
- `user-data/translations/en_zh.tsv`: 英译中注释表。
- `user-data/translations/zh_en.tsv`: 中译英注释表。
- `user-data/translations/custom.tsv`: 手动覆盖的短释义。
- `scripts/build_translation_comments.py`: 重新生成注释表的脚本。

翻译注释来自离线词典，不是联网机器翻译；释义会尽量短，但个别词可能偏词典义。要关闭这个功能，把 `user-data/rime_ice.custom.yaml` 里的 `translation_comment/enabled: true` 改成 `false`，然后重新部署。

## 编程词库

当前额外启用了两层开发/写代码词库：

- `user-data/cn_dicts/thuocl_it.dict.yaml`: 来自 THUOCL 的 IT 中文词库，包含“字符串、初始化、数组、编译器、正则表达式、SQL语句”等约 1.6 万条词。
- `user-data/en_dicts/dev.dict.yaml`: 手工整理的英文开发术语，包含 `API / SDK / TypeScript / Docker / Kubernetes / middleware / callback / pull request / deploy` 等。

这些词库已经分别挂到：

- `user-data/rime_ice.dict.yaml`: 让中文技术词进入雾凇拼音主词库。
- `user-data/melt_eng.dict.yaml`: 让英文开发术语进入英文候选。

部分开发词也在 `user-data/translations/custom.tsv` 里做了短释义覆盖，例如 `middleware -> 中间件`、`deploy -> 部署`、`字符串 -> string`。

## 重新部署

修改词库或配置后运行：

```sh
BASE="/Volumes/工程盘-1T/Rime输入法"
cd "$BASE/user-data"
"$HOME/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel" --build
"$HOME/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel" --reload
```

如果输入法菜单里能看到鼠须管，但打字没有候选窗，可以运行：

```sh
"$BASE/scripts/reload_and_select_squirrel.sh"
```

## 皮肤

当前使用的是 `system_current` 主题；候选高亮色取自当前 macOS 深色模式的系统选中背景色 `RGB(0, 89, 209)`，在鼠须管配置中写作 `0xD15900`。候选窗布局、字体和间距仍由 `user-data/squirrel.custom.yaml` 管理。

鼠须管没有官方皮肤商店，但可以从这些地方找主题或做主题：

- Squirrel Designer: https://github.com/LEOYoon-Tsaw/Squirrel-Designer
- RIME 西米在线生成器: https://gjrobert.github.io/Rime-See-Me-squirrel/
- Catppuccin for Squirrel: https://github.com/catppuccin/squirrel
- Dracula for Rime: https://draculatheme.com/rime

通常做法是把主题里的 `preset_color_schemes` 复制到 `user-data/squirrel.custom.yaml`，再把 `style/color_scheme` 和 `style/color_scheme_dark` 改成对应主题名，最后重新部署。

## 换机迁移

如果能带走完整文件夹，完整步骤见上面的“带着整个文件夹迁移安装”。最核心的是三件事：

- 把整个 `Rime输入法` 文件夹带到新机器。
- 把 `apps/Squirrel.app` 复制到 `~/Library/Input Methods/Squirrel.app`，或运行 `installers/Squirrel-1.1.2.pkg`。
- 把新电脑的 `~/Library/Rime` 链接到本文件夹的 `user-data/`。

注意：macOS 输入法应用本体必须放在系统会扫描的 Input Methods 目录里；真正可迁移的是 `user-data/` 里的方案、词库和用户习惯。

## 开源与商用

下面是工程合规层面的整理，不构成法律意见；正式商业发行前建议再做一次许可证复核。

根目录已经放了 `LICENSE`，建议这个项目整体按 GPL-3.0-only 发布。原因是当前配置包含并修改了 GPL 授权的雾凇拼音 rime-ice，同时本地备份了 GPL 授权的鼠须管 Squirrel。你自己后续新增的脚本、配置和词库覆盖也可以放在同一个 GPL 项目里发布。

能不能商用：可以。GPL 并不禁止商业使用、销售或提供收费服务。但如果你把包含 GPL 内容的修改版分发给别人，需要遵守 GPL 的条件：

- 保留原项目的版权和许可证说明。
- 给接收者提供对应源代码，包括你修改过的部分。
- 允许接收者继续按 GPL 复制、修改、再分发。
- 不把 GPL 部分变成闭源、加密限制或额外禁止再分发的版本。

如果只是自己电脑上使用，或者在自己机器上继续改进而不分发给别人，通常不触发发布源代码的义务。真正对外发布安装包、压缩包、GitHub 仓库或商业交付版本时，就要把许可证、源码和第三方致谢一起带上。

词典数据还要额外注意：CC-CEDICT 和 FrequencyWords 内容是 CC BY-SA 4.0，基于它们生成的派生词库应保留署名，并按相同或兼容的 ShareAlike 条款分享。ECDICT、THUOCL 是 MIT 授权，保留许可证说明即可；THUOCL 上游也建议在学术成果中注明使用了清华大学开放中文词库。

如果将来想做一个更商业宽松的版本，可以把你原创的安装脚本、管理工具单独用 MIT / Apache-2.0 授权，但不要把 rime-ice、Squirrel 或 CC BY-SA 数据重新授权成闭源私有内容。更干净的做法是：仓库只放你的原创工具和配置补丁，安装时再从上游下载这些第三方组件。

第三方组件和许可证清单见 `NOTICE.md`。

## 开源前检查

推到 GitHub 前，建议先确认这些内容：

- 不提交个人状态：`user-data/user.yaml`、`user-data/installation.yaml`、`user-data/english_learning.tsv`、`user-data/*.userdb/`、`user-data/build/`。
- 不提交本地应用和安装包备份：`apps/`、`installers/` 可以靠 README 在线安装脚本重新下载。
- 大型词典源文件可以不进仓库：例如 `sources/ecdict/*.csv`、`sources/cedict/*.u8`；保留生成脚本和下载说明即可。
- 保留 `LICENSE` 和 `NOTICE.md`，并在 README 里说明本项目基于哪些上游项目。

我已经加了 `.gitignore` 来默认排除这些本地/生成文件。

## 来源

| 来源 | 用途 | 协议/说明 |
| --- | --- | --- |
| Rime / librime: https://github.com/rime/librime | 输入法核心引擎 | BSD-3-Clause |
| 鼠须管 Squirrel: https://github.com/rime/squirrel | macOS 输入法前端 | GPL-3.0 |
| 雾凇拼音 rime-ice: https://github.com/iDvel/rime-ice | 中文主方案和基础词库 | GPL-3.0-only |
| 清华开放中文词库 THUOCL: https://github.com/thunlp/THUOCL | IT / 编程中文词库 | MIT，可商用；学术使用建议引用 |
| 法语频率词表 FrequencyWords: https://github.com/hermitdave/FrequencyWords | 法语候选词表 | 代码 MIT；内容 CC BY-SA 4.0 |
| 英汉词典 ECDICT: https://github.com/skywind3000/ECDICT | 英文候选中文注释 | MIT |
| 中英词典 CC-CEDICT: https://www.mdbg.net/chinese/dictionary?page=cc-cedict | 中文候选英文注释 | CC BY-SA 4.0 |
