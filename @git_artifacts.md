# Git Workflow Artifacts

## Recommended Branch Name
`feat/location-debug-and-bus-arrival-limit`

## Recommended Issue Content

```markdown
---
name: ✨ Feature request
about: Suggest an idea for this project
title: "[Feature] 위치 디버그 모드 및 노선별 버스 도착 정보 제한 구현"
labels: "feature"
assignees: ""
---

### 🚀 Feature Description

이슈를 설명하는 간결하고 명확한 문장을 작성해주세요.

- **위치 디버그 모드 구현:**
  - 개발 과정에서 특정 위치(수유역/대구대학교)에서의 동작을 쉽게 테스트하기 위한 디버그 모드를 구현합니다.
  - 디버그 설정이 앱 재시작 시에도 유지되도록 합니다.
  - `LocationManager`에 모의 위치 기능을 추가하고, `DebugView`에 토글 UI를 구현합니다.
  - `UserDefaults`를 통해 설정 상태를 저장하고, `LocationManager`를 싱글톤으로 변경하여 일관된 디버그 상태를 유지합니다.

- **노선별 버스 도착 정보 제한:**
  - `BusStationViewModel`에서 노선별 도착 정보를 최대 2개로 제한하여 UI 표시를 최적화합니다.
  - `fetchStopArrivals` 결과 중 각 노선별로 가장 가까운 2개의 도착 정보만 사용하도록 수정합니다.

- **로컬라이제이션 업데이트:**
  - 위 기능들에 필요한 새로운 문자열 리소스가 `Localizable.xcstrings`에 추가되었습니다.

### 💡 Why is this feature needed?

이 기능이 필요한 이유를 설명해주세요.

- 개발 효율성 증대: 위치 기반 기능 테스트의 용이성 확보.
- 사용자 경험 개선: 버스 도착 정보 표시의 가독성 및 UI 최적화.
- 코드 유지보수성 향상: 디버그 기능의 체계적인 관리.

### 📝 Proposed Solution

이 기능을 어떻게 구현할 것인지에 대한 간략한 설명을 작성해주세요.

- `LocationManager`에 디버그용 위치 설정 로직 추가.
- `DebugView`에 위치 디버그 토글 및 관련 UI 구현.
- `BusStationViewModel`의 `fetchStopArrivals` 처리 로직 수정.
- `Localizable.xcstrings` 파일 업데이트.

### ✅ Acceptance Criteria

이 기능이 완료되었음을 판단하는 기준을 작성해주세요.

- [ ] 앱 내에서 위치 디버그 모드를 활성화/비활성화할 수 있다.
- [ ] 디버그 모드에서 특정 위치(수유역/대구대학교)로 모의 위치를 설정할 수 있다.
- [ ] 모의 위치 설정이 앱 재시작 후에도 유지된다.
- [ ] `BusStationViewModel`에서 각 노선별 버스 도착 정보가 최대 2개만 표시된다.
- [ ] 모든 새로운 UI 텍스트가 `Localizable.xcstrings`를 통해 올바르게 현지화된다.

### 🖼️ Screenshots or Mockups (Optional)

스크린샷이나 목업이 있다면 첨부해주세요.
```

## Recommended PR Title and Content

```markdown
---
name: ✨ Feature
about: Implement a new feature
title: "✨ Feat: 위치 디버그 모드 및 노선별 버스 도착 정보 제한 구현"
labels: "feature"
assignees: ""
---

## 🚀 PR Type

- [x] Feature
- [ ] Bugfix
- [ ] Refactor
- [ ] Chore
- [ ] Docs

## 📖 Description

이 PR에서 어떤 변경 사항이 있었는지 자세히 설명해주세요.

- **위치 디버그 모드 구현:**
  - 개발 과정에서 특정 위치(수유역/대구대학교)에서의 동작을 쉽게 테스트하기 위한 디버그 모드를 구현했습니다.
  - 디버그 설정이 앱 재시작 시에도 유지되도록 `UserDefaults`를 사용했습니다.
  - `LocationManager`에 모의 위치 기능을 추가하고, `DebugView`에 토글 UI를 구현했습니다.
  - `LocationManager`를 싱글톤으로 변경하여 일관된 디버그 상태를 유지하도록 했습니다.
  - 관련 파일: `LocationManager.swift`, `BusDetectionViewController.swift`, `DebugView.swift`, `AppRouter.swift`

- **노선별 버스 도착 정보 제한:**
  - `BusStationViewModel`에서 노선별 도착 정보를 최대 2개로 제한하여 UI 표시를 최적화했습니다.
  - `fetchStopArrivals` 결과 중 각 노선별로 가장 가까운 2개의 도착 정보만 사용하도록 수정했습니다.
  - 관련 파일: `BusStationViewModel.swift`

- **로컬라이제이션 업데이트:**
  - 위 기능들에 필요한 새로운 문자열 리소스가 `Localizable.xcstrings`에 추가되었습니다.
  - 관련 파일: `Localizable.xcstrings`

## ✅ Checklist

- [x] 코드 스타일 가이드라인을 준수했습니다.
- [x] 새로운 기능에 대한 테스트를 작성했습니다. (해당하는 경우)
- [x] 변경 사항이 기존 기능에 영향을 미치지 않음을 확인했습니다.
- [x] 문서 업데이트가 필요한 경우, 문서를 업데이트했습니다.

## 📸 Screenshots (Optional)

스크린샷이나 GIF를 첨부해주세요.
```
