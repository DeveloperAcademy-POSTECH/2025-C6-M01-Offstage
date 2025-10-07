#!/bin/sh
set -euo pipefail
set -x  # 디버그: 실행되는 명령을 echo

# 1) mise 찾기 (PATH에 없을 때 대체 경로 시도)
if command -v mise >/dev/null 2>&1; then
  MISE_BIN="$(command -v mise)"
elif [ -x "/opt/homebrew/bin/mise" ]; then
  MISE_BIN="/opt/homebrew/bin/mise"
elif [ -x "$HOME/.local/bin/mise" ]; then
  MISE_BIN="$HOME/.local/bin/mise"
else
  echo "error: mise not found in PATH or common locations" >&2
  exit 1
fi

# 2) 설정 파일 존재 확인
LINT_CFG="$PROJECT_DIR/.swiftlint.yml"
if [ ! -f "$LINT_CFG" ]; then
  echo "warning: $LINT_CFG not found; skipping SwiftLint" >&2
  exit 0
fi

# 3) lint 실행 (경고는 허용: --strict 미사용)
"$MISE_BIN" x -- swiftlint --config "$LINT_CFG" --reporter xcode || true
# ↑ 린트가 경고/비치명적 사유로 비영 종료해도 빌드는 계속 진행