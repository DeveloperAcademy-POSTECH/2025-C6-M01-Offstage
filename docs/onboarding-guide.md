# 🚀 OffStageApp 온보딩 가이드

이 문서는 빠르게 프로젝트를 시작하고, 팀 규칙을 따를 수 있도록 돕기 위한 가이드입니다.  
환경 설정부터 브랜치/커밋 규칙, 개발 워크플로우까지 단계별로 정리되어 있습니다.  

---

## 1. 환경 설정

### 📦 필수 설치 도구
- [mise](https://mise.jdx.dev) → 프로젝트 내 도구 버전 관리
- Git
- Xcode (최신 안정 버전)

### ⚡️ 초기 설정
```bash
git clone https://github.com/DeveloperAcademy-POSTECH/2025-C6-M01-Offstage.git
cd 2025-C6-M01-Offstage

# mise로 필요한 도구 설치 & hooks 설치 & commit template 등록
make setup

# 👉 이후 Xcode 실행을 위해 프로젝트를 생성해야 합니다
make tuist-generate
```

`make setup`은 다음을 자동으로 실행합니다:
- mise install → SwiftFormat, SwiftLint, Tuist, Lefthook 설치
- git hooks 등록 (브랜치명/커밋메시지 검사)
- commit template 등록 (`.gitmessage.txt`)

---

## 2. 브랜치 규칙

### 📌 형식
```
<type>/<issue-number>-<kebab-case-description>
```

- `type`: feature / bugfix / hotfix  
- `issue-number`: GitHub 이슈 번호 (권장)  
- `description`: 소문자와 하이픈(`-`)으로 간단히 설명  

✅ 예시:
- `feature/12-healthkit-setup`
- `bugfix/45-missing-data-sync`
- `hotfix/73-app-launch-crash`

❌ 잘못된 예시:
- `main` (보호 브랜치 직접 작업 금지)  
- `fix/login` (prefix 불일치, 이슈 번호 없음)

👉 더 자세한 설명은 [`docs/branch-guide.md`](branch-guide.md)를 참고하세요.

---

## 3. 커밋 메시지 규칙

### 📌 기본 형식
```
<Gitmoji> <Type>. 요약 설명

Why:
- 변경 이유

How:
- 변경 방법

Tags: #관련태그
```

- `<Type>`은 대문자로 시작 (예: Feat, Fix, Docs, Refactor 등)
- `Why / How / Tags`는 선택적이지만 권장

✅ 예시:
```
♻️ Refactor. DateFormatter 인스턴스 개선

Why:
- 불필요한 매번 생성으로 성능 저하

How:
- 싱글톤 패턴 적용
```

❌ 잘못된 예시:
- `fix: 로그인 고침` (형식 위반)  
- `readme 업데이트` (규칙 미준수)

> `.gitmessage.txt` 파일이 커밋 템플릿으로 등록되어 있으므로, `git commit` 시 자동으로 템플릿이 열립니다.  

👉 더 자세한 설명은 [`docs/commit-guide.md`](commit-guide.md)를 참고하세요.

---

## 4. 개발/검증 워크플로우

우리 팀은 **코드 품질 관리**를 위해 포맷터(정렬), 린터(코드 규칙 검사), 그리고 Tuist(프로젝트 생성)를 자동화했습니다.  
아래 명령어로 개발 시점과 CI(검증) 시점에 필요한 절차를 쉽게 실행할 수 있습니다.  

### 🔹 `make verify` (로컬 개발용)
👉 **내가 작성한 코드를 정리하고 검사한 후, 프로젝트를 다시 생성**

실행 단계:
1. **SwiftFormat** → 코드 스타일 자동 정리 (띄어쓰기, 줄바꿈, 들여쓰기 등)
2. **SwiftLint autocorrect** → 단순 위반 자동 수정
3. **SwiftLint lint (non-strict)** → 코드 검사 (경고는 허용)
4. **Tuist generate** → Xcode 프로젝트 다시 생성

사용 시점:
- 새로운 코드를 작성하거나 PR 올리기 전, 코드 품질 점검이 필요할 때

---

### 🔹 `make verify-ci` (CI/CD용)
👉 **자동화 환경에서, 코드가 규칙을 어겼는지 검사 (수정은 하지 않음)**

실행 단계:
1. **SwiftFormat lint-only** → 코드 포맷 검사만 (수정 안 함)
2. **SwiftLint strict** → 모든 경고를 오류로 처리
3. **Tuist generate** → 프로젝트 생성 검증

사용 시점:
- GitHub Actions 같은 CI 서버에서 PR 검사 시 실행됨

---

### 🔹 개별 실행 커맨드
- `make format` → SwiftFormat 적용 (수정 모드)
- `make lint` → SwiftLint 검사 (non-strict)
- `make tuist-generate` → Tuist 기반 Xcode 프로젝트 생성
- `make clean` → 생성물 정리 (Derived, *.xcodeproj, *.xcworkspace 등)

---

## 5. Git Hooks

프로젝트에는 **자동 검사 훅(hook)**이 설치되어 있습니다.  
- `pre-commit` → 브랜치명 검사 + SwiftFormat  
- `commit-msg` → 커밋 메시지 규칙 검사  

테스트는 아래 명령어로 가능합니다:
```bash
make test-hooks
```

---

## ✅ 요약

1. `make setup` → 환경 준비 완료 (mise 도구 설치 + hooks + commit 템플릿)  
2. `make tuist-generate` → Xcode 실행 준비  
3. 브랜치는 `feature/번호-설명` 형식으로 생성  
4. 커밋 메시지는 `<Gitmoji> Type. 요약` + Why/How/Tags  
5. 개발 시 `make verify`, CI는 `make verify-ci`로 검사  
6. PR은 항상 규칙에 맞춘 브랜치와 커밋만 제출  

---

💡 미흡한 점이나 개선이 필요한 부분이 있으면 언제든 ISSUE 등록 바랍니다!
