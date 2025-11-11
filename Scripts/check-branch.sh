#!/bin/bash

BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)

# ✅ 예외 브랜치 (GitHub 자동 브랜치 등)
if echo "$BRANCH_NAME" | grep -qE "^(main|develop|release|dependabot/.*)$"; then
  exit 0
fi

# Detached HEAD 또는 일부 상황(예: amend)에서 git rev-parse --abbrev-ref HEAD가
# 'HEAD'를 반환합니다. 이 경우 브랜치 네이밍 검사로 인해 불필요하게 실패하므로
# 로컬 커밋 작업(예: --amend) 시에는 검사를 건너뜁니다.
if [ "$BRANCH_NAME" = "HEAD" ] || [ -z "$BRANCH_NAME" ]; then
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