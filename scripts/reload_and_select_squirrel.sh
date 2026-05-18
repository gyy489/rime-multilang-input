#!/usr/bin/env bash
set -euo pipefail

app="$HOME/Library/Input Methods/Squirrel.app"
bin="$app/Contents/MacOS/Squirrel"

if [[ ! -x "$bin" ]]; then
  echo "Squirrel is not installed at: $app" >&2
  exit 1
fi

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
