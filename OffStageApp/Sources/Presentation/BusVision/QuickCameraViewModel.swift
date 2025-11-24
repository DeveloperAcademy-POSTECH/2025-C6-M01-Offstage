import BusAPI
import Combine
import Foundation

class QuickCameraViewModel: ObservableObject {
    // MARK: - Properties

    let busNumberToDetect: String

    /// VC에서 감지된 raw 감지된 status값
    @Published var busDetectedState: BusDetectStatus = .unDetected

    /// UI에 보여줄 버스감지 상태
    @Published var stateToPresent: BusDetectStatus = .unDetected

    /// 내 버스가 감지된 시간
    private var lastMineDetectedTime: Date?

    private var hapticManager = HapticManager.shared
    private var ttsManager: TTSManager = .init()
    private var tiltDataCollector: TiltDataCollector
    var tiltManager: TiltManager
    private var cancellables = Set<AnyCancellable>()
    private var detectingHapticTimer: Timer?
    private var shouldPlayDetectingHaptic: Bool = true

    // MARK: - init

    init(routeNo: String) {
        // busRoute.routeNumber에서 괄호 내용 제거
        busNumberToDetect = routeNo.removeParenthesesContent()

        tiltDataCollector = TiltDataCollector()
        tiltManager = TiltManager(dataCollector: tiltDataCollector)

        // combine 등록
        observeBusDetectStatus()
        observeTiltStateChanges()

        // 감지중 햅틱 피드백 시작
        startDetectingFeedback()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.ttsManager.speakNow(of: "버스 인식을 위해 카메라를 어깨 위로 들어주세요.")
        }
    }

    deinit {
        stopDetectingFeedback()
        tiltManager.disableHapticFeedback()
    }
}

// MARK: - 비전 버스 감지

extension QuickCameraViewModel {
    private func observeBusDetectStatus() {
        $busDetectedState
            .sink { [weak self] status in
                switch status {
                case let .mineDetected(routeNo):
                    self?.myBusFeedback(routeNo)
                    self?.stateToPresent = status
                    self?.lastMineDetectedTime = Date()
                    self?.shouldPlayDetectingHaptic = false

                case .notMine:
                    // mineDetected 후 1초 이내면 상태 변경 무시
                    if let lastTime = self?.lastMineDetectedTime,
                       Date().timeIntervalSince(lastTime) < 1.0
                    {
                        return
                    }
                    self?.stateToPresent = status
                    self?.notMineFeedback()
                    self?.shouldPlayDetectingHaptic = false

                case .unDetected:
                    // mineDetected 후 1초 이내면 상태 변경 무시
                    if let lastTime = self?.lastMineDetectedTime,
                       Date().timeIntervalSince(lastTime) < 1.0
                    {
                        return
                    }
                    self?.stateToPresent = status
                    self?.shouldPlayDetectingHaptic = true
                }
            }
            .store(in: &cancellables)
    }

    /// 내 버스가 인식된 경우 햅틱과 TTS재생
    private func myBusFeedback(_ detectedRouteNo: String) {
        // 햅틱
        hapticManager.playHaptic(intensity: 1.0, sharpness: 1.0, duration: 0.2)

        // TTS
        ttsManager.speakNow(of: "\(detectedRouteNo)번 버스. 버스를 향해 손을 흔들어주세요")
    }

    /// 다른 버스가 인식된 경우  TTS재생
    private func notMineFeedback() {
        ttsManager.speakNow(of: "다른 번호의 버스입니다.")
    }

    private func startDetectingFeedback() {
        detectingHapticTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true, block: { [weak self] _ in
            guard let self, shouldPlayDetectingHaptic else { return }
            hapticManager.playHapticsFile(named: "Waiting")
        })
    }

    private func stopDetectingFeedback() {
        detectingHapticTimer?.invalidate()
        detectingHapticTimer = nil
    }
}

// MARK: - 기울기 상태 관찰

extension QuickCameraViewModel {
    private func observeTiltStateChanges() {
        tiltManager.$publishedTiltState
            .removeDuplicates()
            .sink { [weak self] tiltState in
                self?.handleTiltStateChange(tiltState)
            }
            .store(in: &cancellables)
    }

    private func handleTiltStateChange(_ tiltState: TiltState) {
        if tiltState == .forward || tiltState == .backward {
            let message = switch tiltState {
            case .forward:
                "휴대폰을 몸 안쪽으로 기울여주세요"
            case .backward:
                "휴대폰을 몸 바깥쪽으로 기울여주세요"
            default:
                ""
            }

            ttsManager.speakNow(of: message)
        }
    }
}
