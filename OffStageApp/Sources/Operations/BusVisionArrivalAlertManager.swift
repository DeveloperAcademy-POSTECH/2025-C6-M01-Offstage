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

    private var timer: Timer?
    private let busStop: BusStop
    private let busRoute: BusRoute
    private let busArrivalOperations: BusArrivalOperations
    private var previousArrivalTime: Int = 0

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
                let newRemainingStopCount: Int
                if let firstArrival = arrivals.first,
                   let estimatedTime = firstArrival.estimatedArrivalTime
                {
                    newArrivalTime = estimatedTime
                    newRemainingStopCount = firstArrival.remainingStopCount ?? 0
                    print("🚌 버스 도착 정보 조회 성공: \(estimatedTime)초 후 도착, 남은 정류장: \(newRemainingStopCount)개")
                } else {
                    // 도착 정보가 없으면 -1로 설정
                    newArrivalTime = -1
                    newRemainingStopCount = -1
                    print("⚠️ 버스 도착 정보 없음")
                }

                await MainActor.run {
                    self.processArrivalInfo(time: newArrivalTime, stop: newRemainingStopCount)
                    self.remainingStops = newRemainingStopCount
                }
            } catch {
                print("❌ 버스 도착 정보 조회 실패: \(error.localizedDescription)")
                // 에러 시 상태를 유지하고 다음 폴링을 기다림
            }
        }
    }

    /// 버스 도착 정보를 처리하고 상태에 따른 알림 로직 실행
    private func processArrivalInfo(time newTime: Int, stop newRemainings: Int) {
        arrivalTime = newTime

        let oldRemainings = remainingStops
        remainingStops = newRemainings

        print(
            "🚌 processArrivalStops - newTime: \(newTime), newRemainings: \(newRemainings), + currentState: \(currentState)"
        )

        switch currentState {
        case .waitingForArrival:
            handleWaitingState(newRemainings)

        case .arrivalAlertSent:
            handleSoonNotifiedState(oldRemainings, newRemainings)
        }

        previousArrivalTime = newTime
    }

    /// 버스 곧 도착 감지 대기 중 상태 처리
    private func handleWaitingState(_ remainingStops: Int) {
        if remainingStops <= 2, remainingStops > 0 {
            // 2개 이하 정류장 남으면 곧도착 알림
            showSoonArrivalNotification()
            currentState = .arrivalAlertSent
        }
    }

    /// 곧도착 알림 완료 상태 처리
    private func handleSoonNotifiedState(_ oldRemainings: Int, _ newRemainingStops: Int) {
        // 도착 정보가 없어진 경우 (버스가 출발/지나간 것으로 판단)
        if newRemainingStops == -1 || (newRemainingStops > oldRemainings && oldRemainings >= 1) {
            currentState = .waitingForArrival
        }
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
}
