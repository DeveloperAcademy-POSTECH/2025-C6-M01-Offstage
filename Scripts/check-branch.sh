#!/bin/bash

BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

# ✅ 예외 브랜치 (GitHub 자동 브랜치 등)
if echo "$BRANCH_NAME" | grep -qE "^(main|develop|release|dependabot/.*)$"; then
  exit 0
fi

# ✅ 허용 prefix 목록 (원하는 값으로 수정 가능)
PREFIX_REGEX="^(feature|bugfix|hotfix|refactor|release|test|ci|docs)/[a-z0-9._-]+$"

if ! echo "$BRANCH_NAME" | grep -Eq "$PREFIX_REGEX"; then
  echo "❌ 브랜치명 형식 오류: '$BRANCH_NAME'"
  echo ""
  echo "👉 올바른 브랜치명 형식: prefix/설명"
  echo "   예: feature/login-form, bugfix/keyboard-crash, docs/update-readme"
  echo ""
  echo "✅ 허용 prefix: feature|bugfix|hotfix|refactor|release|test|ci|docs"
  exit 1
fi

exit 0