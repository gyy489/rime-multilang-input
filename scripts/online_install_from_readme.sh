#!/usr/bin/env bash
set -euo pipefail

BASE="${RIME_PORTABLE_DIR:-$HOME/Rime输入法}"
SQUIRREL_VERSION="1.1.2"
SQUIRREL_PKG="Squirrel-${SQUIRREL_VERSION}.pkg"

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

echo "==> Download Squirrel ${SQUIRREL_VERSION}"
curl -L --fail \
  -o "$BASE/installers/$SQUIRREL_PKG" \
  "https://github.com/rime/squirrel/releases/download/${SQUIRREL_VERSION}/${SQUIRREL_PKG}"

echo "==> Extract and install Squirrel.app"
rm -rf "$BASE/.tmp-squirrel"
mkdir -p "$BASE/.tmp-squirrel/app"
pkgutil --expand "$BASE/installers/$SQUIRREL_PKG" "$BASE/.tmp-squirrel/pkg"
tar -xzf "$BASE/.tmp-squirrel/pkg/Payload" -C "$BASE/.tmp-squirrel/app" ./Squirrel.app
ditto "$BASE/.tmp-squirrel/app/Squirrel.app" "$BASE/apps/Squirrel.app"
mkdir -p "$HOME/Library/Input Methods"
ditto "$BASE/apps/Squirrel.app" "$HOME/Library/Input Methods/Squirrel.app"

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
  style/color_scheme: monochrome_black
  style/color_scheme_dark: monochrome_black
  style/candidate_list_layout: stacked
  style/text_orientation: horizontal
  style/inline_preedit: true
  style/inline_candidate: false
  style/memorize_size: true
  style/translucency: false
  style/mutual_exclusive: false
  style/show_paging: false
  style/corner_radius: 6
  style/hilited_corner_radius: 0
  style/border_height: 0
  style/border_width: 0
  style/line_spacing: 6
  style/spacing: 8
  style/shadow_size: 0
  style/candidate_format: "[label]. [candidate] [comment]"

  preset_color_schemes/monochrome_black:
    name: "Monochrome Black"
    author: "Codex"
    color_space: srgb
    alpha: 1
    back_color: 0x000000
    border_color: 0x000000
    candidate_back_color: 0x000000
    preedit_back_color: 0x000000
    hilited_back_color: 0x000000
    text_color: 0xFFFFFF
    hilited_text_color: 0xFFFFFF
    candidate_text_color: 0xFFFFFF
    label_color: 0xFFFFFF
    comment_text_color: 0xFFFFFF
    hilited_candidate_back_color: 0xFFFFFF
    hilited_candidate_text_color: 0x000000
    hilited_candidate_label_color: 0x000000
    hilited_comment_text_color: 0x000000
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
"$HOME/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel" --build
"$HOME/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel" --reload
"$BASE/scripts/reload_and_select_squirrel.sh"

echo
echo "Done. Log out and log back in, then add Squirrel in System Settings -> Keyboard -> Input Sources."
echo "Install directory: $BASE"
