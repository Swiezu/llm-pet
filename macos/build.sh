#!/usr/bin/env bash
# Builds llm-pet.app (release, ad hoc signed) into build/ and optionally relaunches it.
# usage: macos/build.sh [--open]
set -euo pipefail
name="llm-pet"
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
out="$(cd "$dir/.." && pwd)/build/$name.app"
swift build -c release --package-path "$dir"
bin="$(swift build -c release --package-path "$dir" --show-bin-path)"
rm -rf "$out"
mkdir -p "$out/Contents/MacOS"
cp "$bin/$name" "$out/Contents/MacOS/"
cp "$dir/Resources/Info.plist" "$out/Contents/"
codesign --force --sign - "$out"
if [ "${1:-}" = "--open" ]; then
  osascript -e "tell application id \"pl.frostbyte.$name\" to quit" 2>/dev/null || true
  for _ in {1..25}; do pgrep -x "$name" >/dev/null || break; sleep 0.2; done
  open "$out" 2>/dev/null || { sleep 1; open "$out"; }
fi
echo "$out"
