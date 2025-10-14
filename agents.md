# AGENTS Guidelines for This Repository

This file provides guidance to AGENTS when working with code in this repository.

## Common Commands

### Tuist (프로젝트 관리)
```bash
# 프로젝트 파일 생성 (Tuist가 관리하는 Xcode 프로젝트/워크스페이스 생성)
tuist generate

# 생성된 Xcode 프로젝트 (.xcodeproj 또는 .xcworkspace)를 바로 열기
open ./TaskCombo.xcodeproj

# 주의: 생성된 Xcode 프로젝트는 Tuist가 관리합니다.
# 직접 Xcode 프로젝트 파일을 편집하지 말고, Project.swift 등 Tuist 설정을 수정하세요.
```

### Building and Running (Tuist 기반 권장)
```bash
# 권장: Tuist로 생성 후 Xcode에서 빌드/실행
tuist generate
open ./TaskCombo.xcodeproj
# 또는 Xcode에서 직접 빌드

# CI 또는 커맨드라인 빌드 (Tuist가 제공하는 빌드 래퍼 사용)
tuist build --scheme TaskCombo --configuration Debug

# 대체: 생성된 Xcode 프로젝트에 대해 xcodebuild 사용 가능
xcodebuild -project TaskCombo.xcodeproj -scheme TaskCombo -configuration Debug build
```

### Testing (Tuist 기반 권장)
```bash
# Tuist를 이용한 테스트 실행 (기본)
tuist test --scheme TaskCombo --destination 'platform=iOS Simulator,name=iPhone 15'

# 대체: 생성된 Xcode 프로젝트에 대해 xcodebuild로 테스트 실행
xcodebuild test -project TaskCombo.xcodeproj -scheme TaskCombo -destination 'platform=iOS Simulator,name=iPhone 15'

# 코드 커버리지 필요 시 xcodebuild 플래그 사용(정교한 옵션이 필요하면 xcodebuild 사용 권장)
xcodebuild test -project TaskCombo.xcodeproj -scheme TaskCombo -destination 'platform=iOS Simulator,name=iPhone 15' -enableCodeCoverage YES
```
## Project Architecture
### 1. 전체 아키텍처 개요

TaskCombo는 유즈케이스 중심의 계층화된 아키텍처를 채택합니다. Domain-Driven Design의 원칙을 따르면서도, 앱의 규모에 맞는 실용적인 구조를 유지합니다.

핵심 원칙
- 단순성: 과도한 추상화 지양
- 명확한 책임: 각 계층의 역할이 명확히 구분
- 테스트 용이성: 각 계층을 독립적으로 테스트 가능
- 최신 기술 활용: minimum SDK 를 iOS 18, macOS 15로 지정하여 최대한 최신에 나온 API를 사용함
- SwiftUI 친화적: SwiftUI의 패러다임에 맞는 구조

### 2. 계층 구조
```
┌─────────────────────────────────────────┐
│           Presentation Layer            │
│         (Views & View States)           │
├─────────────────────────────────────────┤
│           Operations Layer              │
│    (Business Logic & Use Cases)        │
├─────────────────────────────────────────┤
│            Domain Layer                 │
│    (Models & Domain Operations)        │
├─────────────────────────────────────────┤
│         Infrastructure Layer            │
│    (Managers & External Services)      │
└─────────────────────────────────────────┘
```

### 3. 각 계층의 역할과 책임
#### 3.1 Presentation Layer (UI)

역할: 사용자 인터페이스와 상호작용 처리

포함 요소:
- SwiftUI Views (ContentView, OnGoingView, etc.)
- View-specific States (@State, @Binding)
- Navigation Logic

책임:
- UI 렌더링
- 사용자 입력 처리
- Operations 호출
- 에러 표시

제한사항:
- 비즈니스 로직 직접 구현 금지
- ModelContext 직접 조작 금지 (Operations를 통해서만)
- Domain 모델의 Write 작업 직접 호출 금지
- SwiftData Model의 데이터를 표시할 때는 @Query와 +Read.swift에서 얻은 FetchDescriptor의 조합만을 사용

#### 3.2 Operations Layer (비즈니스 로직)

역할: 앱의 모든 유즈케이스와 비즈니스 로직 구현

구조:
@Observable
final class Operations {
   // 모든 Manager 인스턴스
   let liveActivityManager: LiveActivityManager
   let widgetManager: WidgetManager
   let notificationManager: MacNotificationManager?

   // 유즈케이스 메서드들
   func startNewRelay(...)
   func completeCurrentTask(...)
   func addToBacklog(...)
}

책임:
- 복잡한 비즈니스 플로우 조정
- 여러 도메인 작업 조합
- 부수 효과 관리 (알림, 위젯 업데이트 등)
- 트랜잭션 경계 관리
- 에러 처리 및 복구

제한사항:
- UI 로직 포함 금지
- View에 의존하지 않음
- 순수한 비즈니스 로직만 포함
- SwiftData의 ModelContext는 클래스 내부에서 관리하지 않고, SwiftUI View에서 Environment(\.modelContext)로 얻은 ModelContext를 전달 받아 사용

#### 3.3 Domain Layer (도메인)

역할: 핵심 비즈니스 엔티티와 규칙 정의

포함 요소:
- Models: Relay, TaskItem, BacklogItem
- Domain Operations:
   - Relay+Read: 읽기 전용 작업
   - Relay+Write: 쓰기 작업
   - Relay+Metrics: 계산 로직

책임:
- 도메인 불변성 보장
- 비즈니스 규칙 적용
- 데이터 일관성 유지
- Aggregate 경계 관리

제한사항:
- 외부 서비스 직접 호출 금지
- UI 관련 로직 포함 금지
- Infrastructure 계층에 의존 금지

#### 3.4 Infrastructure Layer (인프라)

역할: 외부 시스템과의 통합 및 플랫폼 특화 기능

포함 요소:
- Managers (싱글톤 패턴):
   - LiveActivityManager: iOS Live Activity 관리
   - WidgetManager: 위젯 업데이트
   - MacNotificationManager: macOS 알림
   - DataContainerManager: App Group 데이터 공유

책임:
- 플랫폼 API 추상화
- 외부 서비스 통합
- 시스템 리소스 관리

제한사항:
- 비즈니스 로직 포함 금지
- Domain 모델 직접 수정 금지
- 단일 책임 원칙 준수

### 4. 데이터 흐름

#### 4.1 일반적인 흐름

User Action → View → Operations → Domain (+Write) → Infrastructure → External System
               ↑                     ↓
               └──── Domain (+Read) ←┘

#### 4.2 구체적 예시: 작업 완료

1. User: "작업 완료" 버튼 탭
2. View: operations.completeCurrentTask() 호출
3. Operations:
   - Relay.Write.completeTask() 호출
   - liveActivityManager.endActivity() 호출
   - widgetManager.refresh() 호출
   - notificationManager.notify() 호출
4. View: UI 자동 업데이트 (SwiftData @Query)

### 5. 의존성 규칙

의존성 방향

Presentation → Operations → Domain
                  ↓
            Infrastructure

규칙

1. 상위 계층은 하위 계층에 의존 가능
2. 하위 계층은 상위 계층을 모름
3. 동일 계층 간 의존은 최소화
4. 순환 의존 금지

### 6. 테스트 전략

계층별 테스트

1. Domain Layer:
   - 단위 테스트로 비즈니스 규칙 검증
   - In-memory ModelContainer 사용
2. Operations Layer:
   - Mock Manager들을 주입하여 테스트
   - 비즈니스 플로우 검증
3. Infrastructure Layer:
   - 각 Manager 독립적으로 테스트
   - 실제 시스템 API는 Mock 처리
4. Presentation Layer:
   - Preview와 UI 테스트 활용
   - Mock Operations 주입

### 7. 확장 지침

새로운 기능 추가 시

1. Domain: 필요한 모델/규칙 추가
2. Infrastructure: 필요한 Manager 추가
3. Operations: 유즈케이스 메서드 추가
4. Presentation: UI 구현

리팩토링 시

- 각 계층의 경계와 책임을 준수
- 의존성 방향 유지
- 테스트 커버리지 확보 후 진행

이 구조를 통해 TaskCombo는 현재의 단순함을 유지하면서도 향후 확장에 대비한 견고한 기반을 갖추게 됩니다.