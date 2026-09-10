#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: reload_and_select_squirrel.sh [--wait[=seconds]] [--build]

Reload Squirrel, enable the Simplified Chinese input source, and select it.

Options:
  --wait[=seconds]  wait for ~/Library/Rime to become available before reload
                    (default: 120 seconds when no value is provided)
  --build           build schemas from the Rime user directory before reload
USAGE
}

wait_seconds=0
build_first=0
source_id="${RIME_INPUT_SOURCE_ID:-im.rime.inputmethod.Squirrel.Hans}"

for arg in "$@"; do
  case "$arg" in
    --wait)
      wait_seconds="${RIME_WAIT_SECONDS:-120}"
      ;;
    --wait=*)
      wait_seconds="${arg#*=}"
      ;;
    --build)
      build_first=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if ! [[ "$wait_seconds" =~ ^[0-9]+$ ]]; then
  echo "Wait seconds must be a non-negative integer: $wait_seconds" >&2
  exit 2
fi

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

wait_for_rime_dir() {
  local rime_dir="${RIME_USER_DIR:-$HOME/Library/Rime}"
  local elapsed=0
  local target

  while [[ ! -d "$rime_dir" ]]; do
    if (( wait_seconds == 0 || elapsed >= wait_seconds )); then
      if [[ -L "$rime_dir" ]]; then
        target="$(readlink "$rime_dir")"
        echo "Rime user directory is unavailable: $rime_dir -> $target" >&2
      else
        echo "Rime user directory is unavailable: $rime_dir" >&2
      fi
      return 1
    fi

    sleep 1
    elapsed=$((elapsed + 1))
  done

  printf '%s\n' "$rime_dir"
}

source_is_selected() {
  defaults read com.apple.HIToolbox AppleSelectedInputSources 2>/dev/null | grep -Fq "$source_id"
}

rime_dir="$(wait_for_rime_dir)"

if ! app="$(find_squirrel_app)"; then
  echo "Squirrel is not installed in ~/Library/Input Methods or /Library/Input Methods" >&2
  exit 1
fi

bin="$app/Contents/MacOS/Squirrel"

open -g "$app"

if (( build_first )); then
  (cd "$rime_dir" && "$bin" --build)
fi

"$bin" --reload
"$bin" --enable-input-source "$source_id"
if ! source_is_selected; then
  "$bin" --select-input-source "$source_id"
fi

echo "Selected $source_id"
