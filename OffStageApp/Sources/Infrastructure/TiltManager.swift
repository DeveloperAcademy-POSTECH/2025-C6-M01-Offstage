import AVFoundation
import Combine
import Foundation

class TiltManager: ObservableObject {
    // MARK: - Properties

    /// 기준점이 되는 기울기값
    let properTilt: Float = 0.1

    /// 실시간으로 업데이트되는 기울기 값
    @Published var degreeTilt: Float = 0 {
        didSet {
            offsetZ = abs(degreeTilt - properTilt)
            autoUpdateHapticFeedback()
        }
    }

    /// UI 표시용 앞뒤 오프셋 값
    @Published var offsetZ: Float = 0

    /// Published된 기울기 상태 (Combine 사용을 위해)
    @Published var publishedTiltState: TiltState = .normal

    /// Combine 구독을 관리하는 Set
    private var cancellables = Set<AnyCancellable>()

    /// 햅틱 피드백 관리
    private var hapticManager = HapticManager.shared
    private var hapticTimer: Timer?
    private var lastTiltState: TiltState = .normal
    private var hasPlayedCompletionHaptic = false
    private var isHapticEnabled = true

    /// 현재 기울기 상태
    var tiltState: TiltState {
        let tolerance: Float = 0.4
        let tiltDifference = degreeTilt - properTilt

        if tiltDifference > tolerance {
            publishedTiltState = .backward
            return .backward
        } else if tiltDifference < -tolerance {
            publishedTiltState = .forward
            return .forward
        } else {
            publishedTiltState = .normal
            return .normal
        }
    }

    /// 버스 인식에 적합한 기울기 상태인지 확인
    var isSuitableForBusDetection: Bool {
        tiltState == .normal
    }

    /// 기울기 상태별 햅틱 강도 계산 (0.0 ~ 1.0)
    func hapticIntensityForCurrentTilt() -> Float {
        let maxOffset: Float = 1.1 // 실제 최대 오프셋
        let clampedOffset = min(offsetZ, maxOffset)
        return (clampedOffset / maxOffset) * 0.7
    }

    /// 기울기 상태별 가이드 메시지 반환
    var tiltGuideMessage: String {
        switch tiltState {
        case .forward:
            "휴대폰을 몸 안쪽으로 기울여주세요"
        case .backward:
            "휴대폰을 몸 바깥쪽으로 기울여주세요"
        case .normal:
            ""
        }
    }

    // MARK: - init

    /// - Parameters:
    ///   - properTilt: 기준점이 되는 기울기값. 기본값은 (degreeX: 0.0, degreeZ: 0.0)입니다.
    ///   - dataCollector: 기울기 데이터를 제공하는 `TiltDataCollector` 인스턴스
    ///
    /// ## 중요사항
    /// - `dataCollector`는 이미 초기화되고 데이터 수집이 시작된 상태여야 합니다.
    /// - 초기 오프셋 값은 현재 기울기 값과 기준점의 차이로 계산됩니다.
    init(
        dataCollector: TiltDataCollector
    ) {
        dataCollector.$gravityZ
            .map { Float($0) }
            .assign(to: \.degreeTilt, on: self)
            .store(in: &cancellables)

        // 초기 오프셋 값 계산
        offsetZ = abs(degreeTilt - properTilt)
    }

    deinit {
        stopPeriodicHaptic()
    }

    // MARK: - Haptic Feedback Methods

    /// 기울기 상태 변화에 따른 자동 햅틱 피드백 업데이트
    private func autoUpdateHapticFeedback() {
        guard isHapticEnabled else {
            return
        }

        let currentState = tiltState

        switch currentState {
        case .normal:
            // 적정 기울기 달성
            if lastTiltState != .normal, !hasPlayedCompletionHaptic {
                stopPeriodicHaptic()
                playCompletionHaptic()
                hasPlayedCompletionHaptic = true
            }
        case .forward, .backward:
            // 기울기 틀어짐 - 자동으로 주기적 햅틱 시작
            hasPlayedCompletionHaptic = false
            if lastTiltState == .normal || hapticTimer == nil {
                startPeriodicHaptic()
            }
        }

        lastTiltState = currentState
    }

    /// 주기적 햅틱 시작 (강도에 따라 주기 조절)
    private func startPeriodicHaptic() {
        stopPeriodicHaptic()

        let interval = calculateHapticInterval()

        hapticTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            guard let self else { return }

            if tiltState != .normal, isHapticEnabled {
                let intensity = hapticIntensityForCurrentTilt()
                hapticManager.playHaptic(
                    intensity: intensity,
                    sharpness: intensity,
                    duration: 0.1
                )
                startPeriodicHaptic()
            }
        }
    }

    /// 완료 햅틱 재생
    private func playCompletionHaptic() {
        let hapticPattern = [
            hapticManager.makeHaptic(intensity: 1.0, sharpness: 1.0, relativeTime: 0.0, duration: 0.1),
            hapticManager.makeHaptic(intensity: 1.0, sharpness: 1.0, relativeTime: 0.16, duration: 0.1),
        ]

        hapticManager.playHapticPattern(hapticEvents: hapticPattern)
    }

    /// 주기적 햅틱 중지
    private func stopPeriodicHaptic() {
        hapticTimer?.invalidate()
        hapticTimer = nil
    }

    /// 햅틱 주기 계산 (강도에 반비례)
    func calculateHapticInterval() -> TimeInterval {
        let intensity = hapticIntensityForCurrentTilt()

        // 강도가 높을수록 짧은 주기 (0.1초), 낮을수록 긴 주기 (0.5초)
        let minInterval = 0.1
        let maxInterval = 0.5

        // intensity가 1.0이면 minInterval, 0.0이면 maxInterval
        let interval = maxInterval - (Double(intensity) * (maxInterval - minInterval))

        return max(minInterval, min(maxInterval, interval))
    }

    // MARK: - Public Control Methods

    /// 햅틱 피드백 활성화
    func enableHapticFeedback() {
        isHapticEnabled = true
        autoUpdateHapticFeedback()
    }

    /// 햅틱 피드백 비활성화
    func disableHapticFeedback() {
        isHapticEnabled = false
        stopPeriodicHaptic()
        hasPlayedCompletionHaptic = false
    }
}

/// 기울기 상태를 나타내는 열거형
enum TiltState {
    case forward // 앞으로 기울어짐
    case backward // 뒤로 기울어짐
    case normal // 정상 범위
}
