#!/bin/sh
set -euo pipefail
# set -x   # 필요시 디버그

# mise 탐색
if command -v mise >/dev/null 2>&1; then
  MISE_BIN="$(command -v mise)"
elif [ -x "/opt/homebrew/bin/mise" ]; then
  MISE_BIN="/opt/homebrew/bin/mise"
elif [ -x "$HOME/.local/bin/mise" ]; then
  MISE_BIN="$HOME/.local/bin/mise"
else
  echo "error: mise not found" >&2
  exit 1
fi

FMT_CFG="$SRCROOT/.swiftformat"
if [ ! -f "$FMT_CFG" ]; then
  echo "warning: $FMT_CFG not found; skipping SwiftFormat" >&2
  exit 0
fi

# ✅ 실제 수정 + 캐시 무시
"$MISE_BIN" x -- swiftformat "$SRCROOT" --config "$FMT_CFG" --cache ignore