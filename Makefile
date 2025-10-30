# ---------- Makefile (repo root) ----------

SHELL := /bin/bash

# mise exec -- 를 통해 .mise.toml에 정의된 버전의 도구를 실행합니다.
# 개발자는 mise를 미리 설치해야 합니다. (https://mise.jdx.dev)
RUN = mise x --

# 설정 파일 경로 (루트 기준)
FMT_CFG := .swiftformat
LINT_CFG := .swiftlint.yml

.PHONY: setup hooks verify gen format lint clean help register-git-template run

## 개발 환경 설치: mise로 도구 설치 + git hooks/template 등록
setup:
	@echo "[setup] mise로 프로젝트 도구를 설치합니다."
	@mise install
	@$(MAKE) hooks
	@$(MAKE) register-git-template
	@echo "[setup] 완료: 도구 설치 및 git hooks 구성"

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
	@$(MAKE) gen

## 포맷(수정 모드)
format:
	@echo "[swiftformat] 포맷 적용"
	@$(RUN) swiftformat . --config $(FMT_CFG)

## 린트만
lint:
	@echo "[swiftlint] 린트 실행(보고)"
	@$(RUN) swiftlint --config $(LINT_CFG)

## Tuist 프로젝트 생성
gen:
	@echo "[tuist] 프로젝트 생성"
	@$(RUN) tuist generate

## 생성물 정리
clean:
	@rm -rf Derived *.xcodeproj *.xcworkspace graph.dot
	@echo "[clean] 생성 산출물 삭제 완료"

## mise를 통해 명령어 직접 실행 (예: make run tuist edit)
run:
	@$(RUN) $(filter-out $@,$(MAKECMDGOALS))

## 도움말
help:
	@echo "사용 방법:"
	@echo "  make setup           # mise로 도구 설치 후, 자동으로 git hooks 설치까지 수행"
	@echo "  make hooks           # lefthook 기반 git hooks 설치/갱신 (pre-commit, commit-msg)"
	@echo "  make verify          # 포맷(수정) → lint autocorrect → lint(non-strict) → gen"
	@echo "  make format          # SwiftFormat 적용(수정 모드)"
	@echo "  make lint            # SwiftLint 실행(보고)"
	@echo "  make gen             # Tuist 기반 Xcode 프로젝트 생성"
	@echo "  make run [command]   # mise를 통해 명령어 직접 실행 (예: make run tuist edit)"
	@echo "  make clean           # 생성물 정리 (Derived, *.xcodeproj, *.xcworkspace 등)"
