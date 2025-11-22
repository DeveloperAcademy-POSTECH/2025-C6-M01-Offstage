import BusAPI
import Combine
import Foundation

class BusVisionArrivalAlertManager: ObservableObject {
    // MARK: - Properties

    /// 도착예정시간 (초)
    @Published var arrivalTime: Int = 0
    /// 남은 정류장 개수
    @Published var remainingStops: Int = 0
    @Published var currentState: BusNotificationState = .waitingForArrival

    // 알림 표시 상태 (View에서 이걸로 알림뷰 띄움)
    @Published var showSoonArrivalAlert: Bool = false
    @Published var showBusPassedAlert: Bool = false

    private var timer: Timer?
    private let busStop: BusStop
    private let busRoute: BusRoute
    private let busArrivalOperations: BusArrivalOperations
    private var previousArrivalTime: Int = 0

    /// 지나감 대기 중인 버스의 시작 시간 추적
    private var passingWaitStartTime: Date?
    /// 지나감 대기 플래그
    private var isWaitingForPassing: Bool = false
    private var elapsedTime: Int = 0

    // MARK: - Init

    init(busStop: BusStop, busRoute: BusRoute) {
        self.busStop = busStop
        self.busRoute = busRoute
        busArrivalOperations = BusArrivalOperations()
        startTracking()
    }

    deinit {
        stopTracking() // 메모리 해제 시 타이머 정리
    }

    // MARK: - Public Methods

    func startTracking() {
        // 5초마다 API 호출
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }

            // 5초마다 API 호출
            if elapsedTime % 5 == 0 {
                fetchBusArrivalTime()
            }

            if elapsedTime < Int.max - 1 {
                elapsedTime += 1
            } else {
                elapsedTime = 0
            }

            // 도착시간이 줄어드는 걸 보여주기
            if arrivalTime > 0 {
                arrivalTime -= 1
            }
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
        Task {
            do {
                let arrivals = try await busArrivalOperations.fetchArrivalsOnly(
                    busStop: busStop,
                    busRoute: busRoute
                )

                let newArrivalTime: Int
                let remainingStopCount: Int
                if let firstArrival = arrivals.first,
                   let estimatedTime = firstArrival.estimatedArrivalTime
                {
                    newArrivalTime = estimatedTime
                    remainingStopCount = firstArrival.remainingStopCount ?? 0
                    print("🚌 버스 도착 정보 조회 성공: \(estimatedTime)초 후 도착, 남은 정류장: \(remainingStopCount)개")
                } else {
                    // 도착 정보가 없으면 -1로 설정
                    newArrivalTime = -1
                    remainingStopCount = -1
                    print("⚠️ 버스 도착 정보 없음")
                }

                await MainActor.run {
                    self.processArrivalTime(newArrivalTime)
                    self.remainingStops = remainingStopCount
                }
            } catch {
                print("❌ 버스 도착 정보 조회 실패: \(error.localizedDescription)")
                // 에러 시 상태를 유지하고 다음 폴링을 기다림
            }
        }
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
        if time <= 90, time > 0 {
            // 90초 미만이면 곧도착 알림
            showSoonArrivalNotification()
            currentState = .arrivalAlertSent
        }
    }

    /// 곧도착 알림 완료 상태 처리
    private func handleSoonNotifiedState(_ oldTime: Int, _ newTime: Int) {
        // 도착 정보가 없어진 경우 (버스가 출발/지나간 것으로 판단)
        if newTime == -1 || (newTime > oldTime && oldTime >= 0) {
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
        if elapsed >= 0.0 {
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
