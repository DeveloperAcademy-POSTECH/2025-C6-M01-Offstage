import BusAPI
import Combine
import Foundation

class BusVisionViewModel: ObservableObject {
    // MARK: - Properties

    let busNumberToDetect: String
    let busStop: BusStop
    let busRoute: BusRoute

    /// VC에서 감지된 raw 감지된 status값
    @Published var busDetectedState: BusDetectStatus = .unDetected

    /// UI에 보여줄 버스감지 상태
    @Published var stateToPresent: BusDetectStatus = .unDetected

    /// 내 버스가 감지된 시간
    private var lastMineDetectedTime: Date?

    var alertManager: BusVisionArrivalAlertManager
    private var hapticManager = HapticManager.shared
    private var ttsManager: TTSManager = .init()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - init

    init(busStop: BusStop, busRoute: BusRoute) {
        self.busStop = busStop
        self.busRoute = busRoute
        // busRoute.routeNumber에서 괄호 내용 제거
        busNumberToDetect = busRoute.routeNumber.removeParenthesesContent()
        alertManager = .init(busStop: busStop, busRoute: busRoute)
        ttsManager.speakNow(of: "버스 인식을 위해 카메라를 버스 진입 방향으로 비춰주세요")
        // combine 등록
        observeBusDetectStatus()
        setupAlertObservers()
    }

    deinit {
        alertManager.stopTracking()
    }
}

// MARK: - 비전 버스 감지

extension BusVisionViewModel {
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
                       Date().timeIntervalSince(lastTime) < 1.0
                    {
                        return
                    }
                    self?.stateToPresent = status
                }
            }
            .store(in: &cancellables)
    }

    private func myBusFeedback(_ detectedRouteNo: String) {
        // 햅틱
        hapticManager.playHaptic(intensity: 1.0, sharpness: 1.0, duration: 0.2)

        // TTS
        ttsManager.speakNow(of: "\(detectedRouteNo)번 버스가 인식됐어요.")
    }
}

// MARK: - 버스 시간

extension BusVisionViewModel {
    private func setupAlertObservers() {
        // false → true 변화만 감지
        alertManager.$showSoonArrivalAlert
            .removeDuplicates() // 값이 실제로 변경될 때만
            .filter { $0 == true }
            .sink { [weak self] _ in
                self?.handleSoonArrivalAlert()
            }
            .store(in: &cancellables)

        alertManager.$showBusPassedAlert
            .removeDuplicates()
            .filter { $0 == true }
            .sink { [weak self] _ in
                self?.handleBusPassedAlert()
            }
            .store(in: &cancellables)
    }

    func handleSoonArrivalAlert() {
        // 햅틱
        hapticManager.playHaptic(intensity: 1.0, sharpness: 1.0, duration: 0.2)

        // TTS
        ttsManager.speakNow(of: "\(busNumberToDetect)번 버스가 정류장 진입 중입니다.")
    }

    func handleBusPassedAlert() {
        // 햅틱
        hapticManager.playHaptic(intensity: 1.0, sharpness: 1.0, duration: 0.2)

        // TTS
        ttsManager.speakNow(of: "\(busNumberToDetect)번 버스가 정류장을 벗어났습니다.")
    }
}
