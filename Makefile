# ---------- Makefile (repo root) ----------

SHELL := /bin/bash

# mise가 있으면 고정 버전으로 실행, 없으면 PATH의 도구 사용
MISE := $(shell command -v mise 2>/dev/null || echo "")
ifdef MISE
  RUN = $(MISE) x --
else
  RUN =
endif

# 설정 파일 경로 (루트 기준)
FMT_CFG := .swiftformat
LINT_CFG := .swiftlint.yml

.PHONY: setup hooks verify verify-ci gen format lint tuist-generate clean help

## 개발 환경 설치 (mise) + 훅 자동 설치
setup:
	@echo "[setup] mise install"
	@mise install
	@$(MAKE) hooks
	@echo "[setup] 완료: 도구 설치 및 git hooks 구성"

## Git 훅 설치/갱신 (lefthook)
hooks:
	@chmod +x Scripts/check-branch.sh Scripts/check-commit-msg.sh || true
	@$(RUN) lefthook install
	@echo "[hooks] lefthook installed/updated from .lefthook.yml"

## 로컬 통합 검증: 포맷(수정) → autocorrect → 린트(보고) → tuist generate
verify: format
	@echo "[swiftlint] autocorrect"
	@$(RUN) swiftlint autocorrect --config $(LINT_CFG) --format .
	@echo "[swiftlint] lint (non-strict)"
	@$(RUN) swiftlint --config $(LINT_CFG) || true
	$(MAKE) tuist-generate

## CI 통합 검증: 수정 없이 검사 + 엄격
verify-ci:
	@echo "[swiftformat] lint only"
	@$(RUN) swiftformat . --config $(FMT_CFG) --lint
	@echo "[swiftlint] strict lint"
	@$(RUN) swiftlint --config $(LINT_CFG) --strict
	$(MAKE) tuist-generate

## 포맷(수정 모드)
format:
	@echo "[swiftformat] format (apply)"
	@$(RUN) swiftformat . --config $(FMT_CFG)

## 린트만
lint:
	@$(RUN) swiftlint --config $(LINT_CFG)

## Tuist 프로젝트 생성
tuist-generate:
	@echo "[tuist] generate"
	@$(RUN) tuist generate --no-open

## 생성물 정리
clean:
	@rm -rf Derived *.xcodeproj *.xcworkspace graph.dot
	@echo "[clean] 생성 산출물 삭제 완료"

## 브랜치명/커밋메시지 예시 테스트
test-hooks:
	@bash Scripts/test-hooks.sh

## 도움말
help:
	@echo "사용 방법:"
	@echo "  make setup           # mise로 도구 설치 후, 자동으로 git hooks 설치까지 수행"
	@echo "  make hooks           # lefthook 기반 git hooks 설치/갱신 (pre-commit, commit-msg)"
	@echo "  make verify          # 포맷(수정) → lint autocorrect → lint(non-strict) → tuist generate"
	@echo "  make verify-ci       # 포맷(lint only) → lint(strict) → tuist generate (CI용)"
	@echo "  make format          # SwiftFormat 적용(수정 모드)"
	@echo "  make lint            # SwiftLint 실행(보고)"
	@echo "  make tuist-generate  # tuist generate --no-open"
	@echo "  make clean           # 생성물 정리 (Derived, *.xcodeproj, *.xcworkspace 등)"