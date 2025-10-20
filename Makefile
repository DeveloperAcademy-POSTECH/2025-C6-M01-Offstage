# ---------- Makefile (repo root) ----------

SHELL := /bin/bash

# mise가 있으면 고정 버전으로 실행, 없으면 PATH의 도구 사용
MISE := $(shell command -v mise 2>/dev/null || echo "")
ifdef MISE
  RUN = $(MISE) x --
else
  RUN =
endif

# 설치 스크립트 URL (필요 시 실제 설치 URL로 변경)
MISE_INSTALL_URL ?= https://mise.run

# 설정 파일 경로 (루트 기준)
FMT_CFG := .swiftformat
LINT_CFG := .swiftlint.yml

.PHONY: setup hooks verify verify-ci gen format lint tuist-generate clean help check-mise onboard-mise mise-ensure register-git-template

## 개발 환경 설치 (mise) + 훅 자동 설치
setup:
	@echo "[setup] mise 확인 중"
	@$(MAKE) check-mise >/dev/null 2>&1 || $(MAKE) onboard-mise
	@$(MAKE) mise-ensure
	@$(MAKE) hooks
	@$(MAKE) register-git-template
	@echo "[setup] 완료: 도구 설치 및 git hooks 구성"

## mise 존재 여부 검사 (명시적 호출용)
check-mise:
	@if command -v mise >/dev/null 2>&1; then \
	  echo "[check-mise] mise: 정상"; \
	elif [ -x "$$HOME/.local/bin/mise" ]; then \
	  echo "[check-mise] mise가 ~/.local/bin/mise에 있음 (PATH에 없음)"; \
	else \
	  echo "[check-mise] mise: 발견되지 않음"; exit 1; \
	fi

## 온보딩: curl/wget으로 mise 설치 스크립트 실행
onboard-mise:
	@echo "[onboard-mise] $(MISE_INSTALL_URL)에서 mise 설치 중"
	@if command -v curl >/dev/null 2>&1; then \
	  curl -fsSL "$(MISE_INSTALL_URL)" | sh || { echo "[onboard-mise] 설치 실패"; exit 1; }; \
	elif command -v wget >/dev/null 2>&1; then \
	  wget -qO- "$(MISE_INSTALL_URL)" | sh || { echo "[onboard-mise] 설치 실패"; exit 1; }; \
	else \
	  echo "[onboard-mise] mise 설치에는 curl 또는 wget이 필요합니다"; exit 1; \
	fi

## mise가 PATH에 없을 수 있으니 설치된 위치 확인 후 mise install 실행
mise-ensure:
	@echo "[mise-ensure] mise 상태 확인 및 mise install 실행"
	@if command -v mise >/dev/null 2>&1; then \
	  MISE_CMD="mise"; \
	elif [ -x "$$HOME/.local/bin/mise" ]; then \
	  MISE_CMD="$$HOME/.local/bin/mise"; \
	else \
	  echo "[mise-ensure] mise를 찾을 수 없습니다. 설치가 필요합니다."; exit 1; \
	fi; \
	$$MISE_CMD install

## .gitmessage.txt를 로컬 커밋 템플릿으로 등록
register-git-template:
	@echo "[git-template] .gitmessage.txt를 커밋 템플릿으로 등록합니다"
	@if [ -f .gitmessage.txt ]; then \
	  git config --local commit.template .gitmessage.txt && echo "[git-template] 등록 완료: .gitmessage.txt"; \
	else \
	  echo "[git-template] .gitmessage.txt 파일이 없습니다. 등록을 건너뜁니다."; \
	fi

## lefthook 기반 git hooks 설치/갱신
hooks:
	@echo "[hooks] Scripts/*.sh 실행 권한 부여"
	@chmod +x Scripts/*.sh
	@echo "[hooks] lefthook으로 git hooks 설치/갱신"
	@$(RUN) lefthook install

## 로컬 통합 검증: 포맷(수정) → autocorrect → 린트(보고) → tuist generate
verify: format
	@echo "[swiftlint] 자동수정(autocorrect)"
	@$(RUN) swiftlint autocorrect --config $(LINT_CFG) --format .
	@echo "[swiftlint] 린트(비엄격)"
	@$(RUN) swiftlint --config $(LINT_CFG) || true
	$(MAKE) tuist-generate

## 포맷(수정 모드)
format:
	@echo "[swiftformat] 포맷 적용"
	@$(RUN) swiftformat . --config $(FMT_CFG)

## 린트만
lint:
	@$(RUN) swiftlint --config $(LINT_CFG)

## Tuist 프로젝트 생성
gen:
	@echo "[tuist] 프로젝트 생성"
	@$(RUN) tuist generate

## Tuist install
install:
	@echo "[tuist] 프로젝트 install"
	@$(RUN) tuist install

## 생성물 정리
clean:
	@rm -rf Derived *.xcodeproj *.xcworkspace graph.dot
	@echo "[clean] 생성 산출물 삭제 완료"

## 도움말
help:
	@echo "사용 방법:"
	@echo "  make setup           # mise로 도구 설치 후, 자동으로 git hooks 설치까지 수행"
	@echo "  make hooks           # lefthook 기반 git hooks 설치/갱신 (pre-commit, commit-msg)"
	@echo "  make verify          # 포맷(수정) → lint autocorrect → lint(non-strict) → tuist generate"
	@echo "  make format          # SwiftFormat 적용(수정 모드)"
	@echo "  make lint            # SwiftLint 실행(보고)"
	@echo "  make gen  # tuist generate"
	@echo "  make install        # tuist install"
	@echo "  make clean           # 생성물 정리 (Derived, *.xcodeproj, *.xcworkspace 등)"