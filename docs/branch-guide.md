## 🌟 Branch 명명 규칙 (Branch Naming Convention)

### 🔹 기본 형식

```text
<type>/<issue-number>-<kebab-case-description>
```

| 요소 | 설명 |
| --- | --- |
| type | 작업 목적 접두사 (feature, bugfix, hotfix) |
| issue-number | GitHub 이슈 번호(권장) |
| kebab-case-description | 브랜치 기능을 짧고 명료하게 설명 (소문자-hyphen 포함) |

### 📖 브랜치 예시

```text
feature/12-healthkit-setup
bugfix/45-missing-data-sync
hotfix/73-app-launch-crash
```

### 💡 Prefix 목록

| Prefix | 용도 |
| --- | --- |
| feature/ | 새로운 기능 개발 |
| bugfix/ | 버그 수정 및 QA 이슈 처리 |
| hotfix/ | 프로덕션(main) 긴급 수정 |

## 🌲 브랜치 전략 (GitHub Flow + Develop)

GitHub Flow 기반에 develop을 추가해 팀 협업용으로 확장  
![mermaid](https://www.mermaidchart.com/raw/1458408d-a97b-460f-8ad5-e652b9faea64?theme=light&version=v0.1&format=svg)

### 📆 브랜치 구성

| 브랜치명 | 설명 |
| --- | --- |
| main | 실제 서비스 배포 브랜치 |
| develop | 통합 개발 브랜치(기능·버그 브랜치의 대상) |
| feature/* | 기능 단위 브랜치 (develop에서 분기) |
| bugfix/* | 버그 수정 브랜치 (develop에서 분기) |
| hotfix/* | 운영 긴급 수정 (main에서 분기) |

### 🛂 브랜치 병합 흐름

- feature/・bugfix/ 브랜치: develop에서 분기 → 완료 후 develop으로 병합
- hotfix/ 브랜치: main에서 분기 → main 병합 후 같은 hotfix 브랜치를 develop에도 병합
- main → develop 직접 병합은 지양하고, hotfix 브랜치 자체를 병합해 의도를 보존
- develop → main 병합은 릴리즈/QA 완료 시점에만 수행

### 📄 전략 요약

| 흐름 | 설명 |
| --- | --- |
| develop → main | QA 통과 후 릴리즈 시 병합 |
| hotfix/ → main | 프로덕션 긴급 수정 반영 |
| hotfix/ → develop | 동일 수정 사항을 개발 라인에 그대로 반영 |
| feature/, bugfix/ | develop 기준 분기·병합 |

## 🔗 Pull Request & 병합 정책

| 항목 | 내용 |
| --- | --- |
| PR 대상 브랜치 | 반드시 main 또는 develop |
| 리뷰어 | 최소 1명 지정 |
| 상태 확인 | 병합 전 최신화 및 충돌 해결 필수 |

## 📚 요약

- 브랜치는 명명 규칙을 준수해 생성
- 작업 목적별로 feature/, bugfix/, hotfix/ 분기
- 직접 push 금지, PR로 병합
- PR 시 리뷰어 지정·충돌 확인
- QA 완료 후에만 develop → main 병합 수행, hotfix 는 main과 develop 모두에 반영