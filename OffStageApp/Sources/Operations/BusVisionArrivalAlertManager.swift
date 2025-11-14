import Combine
import Foundation

class BusVisionArrivalAlertManager: ObservableObject {
    // MARK: - Properties

    /// 도착예정시간 (초)
    @Published var arrivalTime: Int = 0
    @Published var currentState: BusNotificationState = .waitingForArrival

    // 알림 표시 상태 (View에서 이걸로 알림뷰 띄움)
    @Published var showSoonArrivalAlert: Bool = false
    @Published var showBusPassedAlert: Bool = false

    private var timer: Timer?

    private let targetBusInfo: String
    private var previousArrivalTime: Int = 0

    /// 지나감 대기 중인 버스의 시작 시간 추적
    private var passingWaitStartTime: Date?
    /// 지나감 대기 플래그
    private var isWaitingForPassing: Bool = false

    private var fetchCount = 0 // TODO: API 호출 로직 넣으면서 삭제하기

    // MARK: - Init

    init(busInfo: String) {
        targetBusInfo = busInfo
        startTracking()
    }

    deinit {
        stopTracking() // 메모리 해제 시 타이머 정리
    }

    // MARK: - Public Methods

    func startTracking() {
        // 10초마다 API 호출
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.fetchBusArrivalTime()
        }
        // 즉시 한 번 호출
        fetchBusArrivalTime()
    }

    func stopTracking() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Private Methods

    private func fetchBusArrivalTime() {
        // 임시 API 호출 (실제로는 네트워크 요청)
        Task {
            let newArrivalTime = await callBusAPI(busInfo: targetBusInfo)
            fetchCount += 1

            await MainActor.run {
                self.processArrivalTime(newArrivalTime)
            }
        }
    }

    // TODO: 실제 API 호출 로직 구현
    private func callBusAPI(busInfo _: String) async -> Int {
        // 임시로 줄어들었다가 늘어나는 시간 반환
        let dummyTime = 70 - ((fetchCount % 8) * 10)
        print("dummyTime: \(dummyTime)")
        return dummyTime
    }

    private func processArrivalTime(_ newTime: Int) {
        let oldTime = arrivalTime
        arrivalTime = newTime

        print("🚌 processArrivalTime - newTime: \(newTime), + currentState: \(currentState)")

        switch currentState {
        case .waitingForArrival:
            handleWaitingState(newTime)

        case .arrivalAlertSent:
            handleSoonNotifiedState(oldTime, newTime)
        }

        checkPassingWait()

        previousArrivalTime = newTime
    }

    /// 버스 곧 도착 감지 대기 중 상태 처리
    private func handleWaitingState(_ time: Int) {
        if time < 60, time > 0 {
            // 60초 미만이면 곧도착 알림
            showSoonArrivalNotification()
            currentState = .arrivalAlertSent
        }
    }

    /// 곧도착 알림 완료 상태 처리
    private func handleSoonNotifiedState(_ oldTime: Int, _ newTime: Int) {
        // 0초가 됐다가 다시 시간이 증가하는 경우 감지
        if newTime > oldTime {
            // 버스가 지나갔다고 판단, 30초 카운트다운 시작
            startPassedCountdown()
            currentState = .waitingForArrival
        }
    }

    /// 지나감 대기 상태 관리
    private func checkPassingWait() {
        guard isWaitingForPassing, let startTime = passingWaitStartTime else {
            return
        }

        let elapsed = Date().timeIntervalSince(startTime)
        if elapsed >= 30.0 {
            // 30초 경과, 버스 지나감 알림
            showBusPassedNotification()

            // 지나감 대기 상태 리셋
            isWaitingForPassing = false
            passingWaitStartTime = nil
        }
    }

    private func startPassedCountdown() {
        // 지나감 대기 플래그 설정
        isWaitingForPassing = true
        passingWaitStartTime = Date()

        print("⏰ 버스 지나감 30초 카운트다운 시작")
    }

    // MARK: - Notification Methods

    private func showSoonArrivalNotification() {
        print("🔔 곧 도착합니다!")
        // 알림 뷰 표시
        showSoonArrivalAlert = true

        // 3초 후 자동으로 사라지게
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.showSoonArrivalAlert = false
        }
    }

    private func showBusPassedNotification() {
        print("🔔 버스가 지나갔습니다!")
        // 알림 뷰 표시
        showBusPassedAlert = true

        // 3초 후 자동으로 사라지게
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.showBusPassedAlert = false
        }
    }
}
