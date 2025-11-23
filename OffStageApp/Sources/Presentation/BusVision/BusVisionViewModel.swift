import BusAPI
import Combine
import Foundation

class BusVisionViewModel: ObservableObject {
    // MARK: - Properties

    let busNumberToDetect: String

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
    private var detectingHapticTimer: Timer?
    private var shouldPlayDetectingHaptic: Bool = true

    // MARK: - init

    init(busStop: BusStop, busRoute: BusRoute) {
        // busRoute.routeNumber에서 괄호 내용 제거
        busNumberToDetect = busRoute.routeNumber.removeParenthesesContent()
        alertManager = .init(busStop: busStop, busRoute: busRoute)
        // combine 등록
        observeBusDetectStatus()
        setupAlertObservers()

        // 감지중 햅틱 피드백 시작
        startDetectingFeedback()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.ttsManager.speakNow(of: "버스 인식을 위해 카메라를 어깨 위로 들어주세요.")
        }
    }

    deinit {
        alertManager.stopTracking()
        stopDetectingFeedback()
    }
}

// MARK: - 비전 버스 감지

extension BusVisionViewModel {
    private func observeBusDetectStatus() {
        $busDetectedState
            .sink { [weak self] status in
                guard let self else { return }

                switch status {
                case let .mineDetected(routeNo):
                    myBusFeedback(routeNo)
                    stateToPresent = status
                    lastMineDetectedTime = Date()
                    shouldPlayDetectingHaptic = false

                case .notMine:
                    // mineDetected 후 1초 이내면 상태 변경 무시
                    if let lastTime = lastMineDetectedTime,
                       Date().timeIntervalSince(lastTime) < 1.0
                    {
                        return
                    }
                    stateToPresent = status
                    notMineFeedback()
                    shouldPlayDetectingHaptic = false

                case .unDetected:
                    // mineDetected 후 1초 이내면 상태 변경 무시
                    if let lastTime = lastMineDetectedTime,
                       Date().timeIntervalSince(lastTime) < 1.0
                    {
                        return
                    }
                    stateToPresent = status
                    shouldPlayDetectingHaptic = true
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
            print("기다리는중 피드백")
            hapticManager.playHapticsFile(named: "Waiting")
        })
    }

    private func stopDetectingFeedback() {
        detectingHapticTimer?.invalidate()
        detectingHapticTimer = nil
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
