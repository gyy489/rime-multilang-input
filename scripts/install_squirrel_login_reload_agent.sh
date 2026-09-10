#!/usr/bin/env bash
set -euo pipefail

label="com.local.rime-squirrel-login-reload"
uid="$(id -u)"
agent_domain="gui/$uid"
plist="$HOME/Library/LaunchAgents/$label.plist"
runner_dir="$HOME/Library/Application Support/Rime输入法"
runner="$runner_dir/reload-squirrel-at-login.sh"
log_dir="$HOME/Library/Logs/Rime输入法"

xml_escape() {
  local value="$1"
  value="${value//&/&amp;}"
  value="${value//</&lt;}"
  value="${value//>/&gt;}"
  value="${value//\"/&quot;}"
  value="${value//\'/&apos;}"
  printf '%s' "$value"
}

uninstall() {
  launchctl bootout "$agent_domain" "$plist" >/dev/null 2>&1 || true
  rm -f "$plist" "$runner"
  echo "Removed $label"
}

if [[ "${1:-}" == "--uninstall" ]]; then
  uninstall
  exit 0
fi

mkdir -p "$HOME/Library/LaunchAgents" "$runner_dir" "$log_dir"

cat > "$runner" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

wait_seconds="${RIME_LOGIN_WAIT_SECONDS:-180}"
source_id="${RIME_INPUT_SOURCE_ID:-im.rime.inputmethod.Squirrel.Hans}"
rime_dir="${RIME_USER_DIR:-$HOME/Library/Rime}"
elapsed=0

find_squirrel_app() {
  local candidate
  for candidate in \
    "$HOME/Library/Input Methods/Squirrel.app" \
    "/Library/Input Methods/Squirrel.app"
  do
    if [[ -x "$candidate/Contents/MacOS/Squirrel" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

source_is_selected() {
  defaults read com.apple.HIToolbox AppleSelectedInputSources 2>/dev/null | grep -Fq "$source_id"
}

while [[ ! -d "$rime_dir" ]]; do
  if (( elapsed >= wait_seconds )); then
    if [[ -L "$rime_dir" ]]; then
      echo "Rime user directory is unavailable after ${wait_seconds}s: $rime_dir -> $(readlink "$rime_dir")" >&2
    else
      echo "Rime user directory is unavailable after ${wait_seconds}s: $rime_dir" >&2
    fi
    exit 1
  fi
  sleep 1
  elapsed=$((elapsed + 1))
done

if ! app="$(find_squirrel_app)"; then
  echo "Squirrel is not installed in ~/Library/Input Methods or /Library/Input Methods" >&2
  exit 1
fi

bin="$app/Contents/MacOS/Squirrel"

open -g "$app"
"$bin" --reload
"$bin" --enable-input-source "$source_id"
if ! source_is_selected; then
  "$bin" --select-input-source "$source_id"
fi

echo "Selected $source_id"
SH
chmod +x "$runner"

runner_xml="$(xml_escape "$runner")"
stdout_xml="$(xml_escape "$log_dir/squirrel-login-reload.out.log")"
stderr_xml="$(xml_escape "$log_dir/squirrel-login-reload.err.log")"

cat > "$plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$label</string>
  <key>ProgramArguments</key>
  <array>
    <string>$runner_xml</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>StandardOutPath</key>
  <string>$stdout_xml</string>
  <key>StandardErrorPath</key>
  <string>$stderr_xml</string>
</dict>
</plist>
PLIST

launchctl bootout "$agent_domain" "$plist" >/dev/null 2>&1 || true
launchctl bootstrap "$agent_domain" "$plist"
launchctl enable "$agent_domain/$label"
launchctl kickstart -k "$agent_domain/$label" >/dev/null 2>&1 || true

echo "Installed $label"
echo "Runner: $runner"
echo "Logs: $log_dir/squirrel-login-reload.*.log"
