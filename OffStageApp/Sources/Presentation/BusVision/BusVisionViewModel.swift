import Combine
import Foundation

class BusVisionViewModel: ObservableObject {
    
    // MARK: - Properties
    
    /// VC에서 감지된 raw 감지된 status값
    @Published var busDetectedState: BusDetectStatus = .unDetected
    
    /// UI에 보여줄 버스감지 상태
    @Published var stateToPresent: BusDetectStatus = .unDetected
    
    /// 내 버스가 감지된 시간
    private var lastMineDetectedTime: Date?

    private var hapticManager = HapticManager.shared
    private var ttsManager: TTSManager = .init()
    private var cancellables = Set<AnyCancellable>()
    

    init() {
        observeBusDetectStatus()
    }

    // MARK: - Methods
    
    private func observeBusDetectStatus() {
        $busDetectedState
            .sink { [weak self] status in
                switch status {
                case let .mineDetected(routeNo):
                    self?.myBusFeedback(routeNo)
                    self?.stateToPresent = status
                    self?.lastMineDetectedTime = Date()
                    
                default:
                    // mineDetected 후 1초 이내면 상태 변경 무시
                    if let lastTime = self?.lastMineDetectedTime,
                       Date().timeIntervalSince(lastTime) < 1.0 {
                        return
                    }
                    self?.stateToPresent = status
                }
            }
            .store(in: &cancellables)
    }

    private func myBusFeedback(_ detectedRouteNo: String) {
        // 햅틱
        hapticManager.playHaptic(intensity: 1.0, sharpness: 0.0, duration: 0.2)

        // TTS
        ttsManager.speakNow(of: "\(detectedRouteNo)번 버스가 인식됐어요.")
    }
}
