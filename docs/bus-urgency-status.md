# BusUrgencyStatus 규격 및 시간 기반 깜빡임 문제 문서

## 📋 목차
1. [개요](#개요)
2. [시간 기반 깜빡임 문제](#시간-기반-깜빡임-문제)
3. [BusUrgencyStatus 현재 규격](#busuργencystatus-현재-규격)
4. [적용 사례](#적용-사례)
5. [향후 고려사항](#향후-고려사항)

---

## 개요

이 문서는 **버스 도착 정보 시스템**에서 발생했던 **'시간 기반 깜빡임(Time-based Flickering)' 문제**와, 이를 해결하기 위해 도입된 **`BusUrgencyStatus` 도메인 모델**의 설계 규격을 상세히 기록합니다.

**관련 이슈:** #145  
**작성일:** 2025-11-12  
**최종 수정:** 2025-11-12

---

## 시간 기반 깜빡임 문제

### 🐛 문제 정의

**증상:**  
'버스 인식하기' 버튼의 활성화 조건을 **"도착 예정 시간이 60초 미만"**으로 설정했을 때, API 갱신 주기마다 버튼이 **활성화 ↔ 비활성화를 반복**하는 '깜빡임 현상'이 발생했습니다.

**발생 시나리오:**
```
1. API 호출 (시점 A): 도착 예정 시간 = 55초 → 버튼 활성화 ✅
2. 30초 경과 후 API 재호출 (시점 B): 도착 예정 시간 = 80초 → 버튼 비활성화 ❌
   (교통 상황 변화로 예상 시간이 다시 증가)
3. 다시 30초 경과 후 API 재호출 (시점 C): 도착 예정 시간 = 50초 → 버튼 활성화 ✅
```

### 🔍 근본 원因

**'도착 예정 시간(초)'은 본질적으로 변동성이 높은 값입니다:**
- 실시간 교통 상황 (신호등, 정체 등)
- GPS 정확도 및 API 응답 지연
- 버스 운행 속도의 변화

따라서 **시간 값을 직접 기준**으로 사용하면, API 갱신마다 예측 값이 오락가락하여 UI 상태가 불안정해집니다.

### ✅ 해결 방안

**"남은 정류장 수(Remaining Stops)"를 주 기준으로 변경:**
- 정류장 수는 **고정적이고 단조 감소**하는 값입니다 (감소만 하고 증가하지 않음).
- API 갱신 시에도 값이 갑자기 증가하지 않으므로, UI 상태가 **안정적으로 유지**됩니다.

**하이브리드 로직 추가:**
- 정류장 수를 우선 기준으로 하되, **"60초 미만"을 예외 조건으로 추가**하여 엣지 케이스를 보완했습니다.
- 예: 2정거장 남았지만 교통 체증으로 50초 남은 경우 → `.arrived` 처리

### 📊 히스토리

| 단계 | 로직 기준 | 문제점 | 해결 여부 |
|------|----------|--------|----------|
| **1단계** (초기) | 시간만 기준 (`< 60초`) | ❌ 깜빡임 발생 | 미해결 |
| **2단계** ([6ed027c](https://github.com/DeveloperAcademy-POSTECH/2025-C6-M01-Offstage/commit/6ed027c)) | 정류장만 기준 (`.oneStop`, `.arrived`) | ⚠️ 엣지 케이스 존재 (2정거장 < 1분) | 부분 해결 |
| **3단계** ([5ccaf99](https://github.com/DeveloperAcademy-POSTECH/2025-C6-M01-Offstage/commit/5ccaf99)) | 정류장 우선 + 60초 미만 덮어쓰기 | ✅ 안정적 + 엣지 케이스 보완 | **해결** |

---

## BusUrgencyStatus 현재 규격

### 📐 설계 원칙

1. **남은 정류장 수(Remaining Stops)**를 **1차 기준**으로 버스 긴급도를 분류합니다.
2. **도착 예정 시간(Estimated Time in Seconds)**이 60초 미만일 경우, 정류장 수와 무관하게 **`.arrived`로 최종 덮어쓰기**합니다.
3. 각 긴급도 상태별로 **API 자동 갱신 주기**를 다르게 설정하여 네트워크 비용을 최적화합니다.

### 🗂️ 상태(State) 정의

```swift
public enum BusUrgencyStatus: String {
    case fiveOrMoreStops = "5개 정류장 이상"    // 5개 이상
    case threeOrFourStops = "3-4개 정류장 전"  // 3~4개
    case twoStops = "2개 정류장 전"            // 2개
    case oneStop = "1개 정류장 전"             // 1개
    case arrived = "곧도착"                    // 0개 또는 < 60초
    case notApplicable = "해당 없음"           // 데이터 없음
}
```

### ⏱️ API 갱신 주기 (Refresh Interval)

각 상태별 API 호출 간격은 다음과 같이 정의되어 있습니다:

| 상태 | 남은 정류장 수 | API 갱신 주기 | 비고 |
|------|---------------|--------------|------|
| **fiveOrMoreStops** | 5개 이상 | **90초** | 여유 있는 상황 |
| **threeOrFourStops** | 3~4개 | **60초** | 중간 단계 |
| **twoStops** | 2개 | **30초** | 주의 필요 |
| **oneStop** | 1개 | **15초** | 매우 긴급 |
| **arrived** | 0개 또는 < 60초 | **10초** | 최우선 갱신 |
| **notApplicable** | 데이터 없음 | **15초** (기본값) | 예외 처리 |

```swift
public var refreshIntervalSeconds: UInt64 {
    switch self {
    case .fiveOrMoreStops: 90
    case .threeOrFourStops: 60
    case .twoStops: 30
    case .oneStop: 15
    case .arrived: 10
    case .notApplicable: 15
    }
}
```

### 🧮 상태 계산 로직

**함수 시그니처:**
```swift
public static func status(
    for estimatedTimeInSeconds: Int?, 
    remainingStops: Int?
) -> BusUrgencyStatus
```

**알고리즘:**
```
1. remainingStops가 nil이거나 음수 → .notApplicable
2. remainingStops 기준으로 1차 상태 결정:
   - >= 5 → .fiveOrMoreStops
   - 3~4 → .threeOrFourStops
   - 2 → .twoStops
   - 1 → .oneStop
   - 0 → .arrived
3. estimatedTimeInSeconds < 60 조건 충족 시:
   - 1~2단계에서 결정된 상태를 무시하고 → .arrived로 최종 덮어쓰기
4. 최종 상태 반환
```

**코드 예시:**
```swift
public static func status(for estimatedTimeInSeconds: Int?, remainingStops: Int?) -> BusUrgencyStatus {
    guard let remainingStops, remainingStops >= 0 else {
        return .notApplicable
    }

    var status: BusUrgencyStatus = .notApplicable

    // 1단계: 정류장 수 기반 상태 결정
    if remainingStops >= 5 {
        status = .fiveOrMoreStops
    } else if remainingStops >= 3 {
        status = .threeOrFourStops
    } else if remainingStops == 2 {
        status = .twoStops
    } else if remainingStops == 1 {
        status = .oneStop
    } else if remainingStops == 0 {
        status = .arrived
    }
    
    // 2단계: 60초 미만 예외 처리 (덮어쓰기)
    if let estimatedTime = estimatedTimeInSeconds, estimatedTime < 60 {
        status = .arrived
    }
    
    return status
}
```

### 🔄 하이브리드 로직의 장점

1. **안정성:** 정류장 수 기준으로 깜빡임 방지
2. **반응성:** 60초 미만일 때 즉시 `.arrived` 처리
3. **엣지 케이스 대응:** "2정거장 남았는데 50초" 같은 상황도 정확히 처리

---

## 적용 사례

### 1️⃣ BusArrivalOperations (API 자동 갱신)

**위치:** `OffStageApp/Sources/Operations/BusArrivalOperations.swift`

**동작 방식:**
- `AsyncStream`을 사용하여 주기적으로 버스 도착 정보를 갱신합니다.
- 매 갱신마다 `BusUrgencyStatus`를 재계산하고, 해당 상태의 `refreshIntervalSeconds`를 다음 갱신 주기로 사용합니다.

**코드 흐름:**
```swift
func monitorArrivals(busStop: BusStop, busRoute: BusRoute) -> AsyncStream<BusArrivalUpdate> {
    AsyncStream { continuation in
        var lastUrgencyStatus: BusUrgencyStatus = .notApplicable

        let task = Task {
            await fetchAndYield() // 즉시 첫 조회
            
            while !Task.isCancelled {
                // 마지막 긴급도 상태에 따라 대기 시간 결정
                let interval = lastUrgencyStatus.refreshIntervalSeconds * 1_000_000_000
                try await Task.sleep(nanoseconds: interval)
                
                await fetchAndYield() // 주기적 재조회
            }
        }
    }
}
```

### 2️⃣ BusArrivalViewModel (버튼 활성화 로직)

**위치:** `OffStageApp/Sources/Presentation/Home/SubView/BusArrivalViewModel.swift`

**버튼 활성화 조건:**
```swift
private func updateBusVisionButtonState() {
    if busUrgencyStatus == .oneStop || busUrgencyStatus == .arrived {
        isBusVisionButtonEnabled = true
    } else {
        isBusVisionButtonEnabled = false
    }
}
```

**해석:**
- `.oneStop` (1개 정류장 전) 또는 `.arrived` (곧도착/60초 미만) 상태일 때만 버튼 활성화
- 이로 인해 **안정적이고 예측 가능한 버튼 동작** 구현

### 3️⃣ UI 텍스트 포맷 개선

**남은 시간 표시 로직:**
```swift
func formatArrivalTime(seconds: Int) -> String {
    if seconds < 60 {
        return "\(seconds)초 후"  // "50초 후"
    } else {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return "\(minutes)분 \(remainingSeconds)초 후"  // "2분 30초 후"
    }
}
```

---

## 향후 고려사항

### 🧪 테스트 시나리오 확장
- [ ] 정류장 수가 2개이고 시간이 59초일 때 `.arrived` 처리 검증
- [ ] API 응답 지연 시 이전 상태 유지 여부 확인
- [ ] 버튼 활성화 시 햅틱 중복 호출 방지 로직 검증

### 🔮 개선 아이디어
1. **사용자 설정 추가:**
   - "빠른 응답 모드" (모든 갱신 주기 -10초)
   - "배터리 절약 모드" (모든 갱신 주기 +30초)

2. **학습 기반 예측:**
   - 특정 노선의 과거 데이터 분석 → 도착 예측 정확도 향상
   - ML 모델로 "깜빡임 위험도" 사전 판단

3. **에러 핸들링 강화:**
   - API 호출 실패 시 지수 백오프(Exponential Backoff) 적용
   - 네트워크 상태에 따라 갱신 주기 자동 조절

### 📚 참고 자료
- [Apple Documentation: AsyncStream](https://developer.apple.com/documentation/swift/asyncstream)
- [Apple Documentation: CoreHaptics](https://developer.apple.com/documentation/corehaptics)
- [관련 이슈 #145](https://github.com/DeveloperAcademy-POSTECH/2025-C6-M01-Offstage/issues/145)
- [Commit 6ed027c - 깜빡임 문제 1차 해결](https://github.com/DeveloperAcademy-POSTECH/2025-C6-M01-Offstage/commit/6ed027c)
- [Commit 5ccaf99 - 하이브리드 로직 적용](https://github.com/DeveloperAcademy-POSTECH/2025-C6-M01-Offstage/commit/5ccaf99)

---

## 📝 변경 이력

| 날짜 | 버전 | 변경 내용 | 작성자 |
|------|------|----------|--------|
| 2025-11-12 | 1.0.0 | 초안 작성 (시간 기반 깜빡임 문제 및 BusUrgencyStatus 규격) | @copilot |

---

**문서 작성자:** GitHub Copilot  
**리뷰어:** @bisor0627  
**승인 날짜:** TBD
