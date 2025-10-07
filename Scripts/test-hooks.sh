#!/usr/bin/env bash
set -euo pipefail

BR_OK=(
  "feature/12-healthkit-setup"
  "bugfix/45-missing-data-sync"
  "hotfix/73-app-launch-crash"
)
BR_BAD=(
  "main"                # 보호/직접 작업 금지 대상
  "develop"             # 보호/직접 작업 금지 대상
  "feature/login-ui"    # 이슈 번호 없음
  "fix/123-wrong-type"  # 허용되지 않은 type
)

MSG_OK=(
  "Docs. 문서 구조 개선\n\nWhy:\n- 섹션 정리 필요\n\nHow:\n- 목차 재배치"
  "Fix. 로그인 실패 예외 처리 추가\n\nWhy:\n- 빈 토큰에서 크래시 발생\n\nHow:\n- 조건 분기 및 로그 추가"
  "📝 Docs. 컴포넌트 네이밍 통일\n\nWhy:\n- 중복 네이밍\n\nHow:\n- CycleView→CycleProgressView"
)
MSG_BAD=(
  "readme 업데이트"                         # 형식 위반
  "fix: 로그인 고침"                        # 콜론/소문자 태그, 형식 위반
  "Feat. 너무너무너무너무너무너무길다길다길다" # 요약 과도
)

echo "=== 브랜치명 테스트 (OK) ==="
for b in "${BR_OK[@]}"; do
  if Scripts/check-branch.sh "$b" >/dev/null 2>&1; then
    echo "OK  : $b"
  else
    echo "FAIL: $b"
  fi
done

echo -e "\n=== 브랜치명 테스트 (BAD) ==="
for b in "${BR_BAD[@]}"; do
  if Scripts/check-branch.sh "$b" >/dev/null 2>&1; then
    echo "FAIL: $b"
  else
    echo "OK  : $b"
  fi
done

echo -e "\n=== 커밋 메시지 테스트 (OK) ==="
for m in "${MSG_OK[@]}"; do
  tmpfile="$(mktemp)"
  printf "%b\n" "$m" > "$tmpfile"
  if Scripts/check-commit-msg.sh "$tmpfile" >/dev/null 2>&1; then
    echo "OK  : $(head -n1 "$tmpfile")"
  else
    echo "FAIL: $(head -n1 "$tmpfile")"
  fi
  rm -f "$tmpfile"
done

echo -e "\n=== 커밋 메시지 테스트 (BAD) ==="
for m in "${MSG_BAD[@]}"; do
  tmpfile="$(mktemp)"
  printf "%b\n" "$m" > "$tmpfile"
  if Scripts/check-commit-msg.sh "$tmpfile" >/dev/null 2>&1; then
    echo "FAIL: $(head -n1 "$tmpfile")"
  else
    echo "OK  : $(head -n1 "$tmpfile")"
  fi
  rm -f "$tmpfile"
done

echo -e "\n완료."