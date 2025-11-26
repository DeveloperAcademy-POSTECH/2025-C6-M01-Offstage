import BusAPI
import Combine
import CoreHaptics
import CoreLocation
import Foundation

@MainActor
final class BusArrivalViewModel: ObservableObject {
    // MARK: - Published 속성

    @Published var routeWithArrival: BusRouteWithArrival?
    @Published var busLocationInfo: BusLocation?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentEstimatedArrivalTime: Int?
    @Published var isNavigating = false

    // MARK: - 속성

    let busStop: BusStop
    let busRoute: BusRoute
    private let busArrivalOperations: BusArrivalOperations
    private var arrivalMonitoringTask: Task<Void, Never>?
    private var countdownTimer: Timer?
    private let hapticManager = HapticManager.shared

    // Haptic 중복 방지 플래그
    private var hasVibratedAtSecondStop = false

    // MARK: - 초기화

    init(
        busStop: BusStop,
        busRoute: BusRoute,
        initialArrival: BusArrival? = nil,
        busArrivalOperations: BusArrivalOperations = BusArrivalOperations()
    ) {
        self.busStop = busStop
        self.busRoute = busRoute
        self.busArrivalOperations = busArrivalOperations

        if let arrival = initialArrival {
            routeWithArrival = BusRouteWithArrival(route: busRoute, arrival: arrival)
            currentEstimatedArrivalTime = arrival.estimatedArrivalTime
        }
    }

    deinit {
        arrivalMonitoringTask?.cancel()
        countdownTimer?.invalidate()
    }

    // MARK: - 공개 메서드

    func startMonitoring() {
        // 자동 새로고침이 아닌 첫 로드 시에만 로더를 표시합니다.
        if arrivalMonitoringTask == nil {
            isLoading = true
        }
        errorMessage = nil

        // 여러 스트림이 실행되는 것을 방지하기 위해 이전 작업을 취소합니다.
        arrivalMonitoringTask?.cancel()

        arrivalMonitoringTask = Task {
            let stream = busArrivalOperations.monitorArrivals(busStop: busStop, busRoute: busRoute)
            for await update in stream {
                handleArrivalUpdate(update)
            }
        }
    }

    func stopMonitoring() {
        arrivalMonitoringTask?.cancel()
        arrivalMonitoringTask = nil
        stopCountdownTimer()
        hasVibratedAtSecondStop = false
    }

    func navigateToBusVision() -> (busStop: BusStop, busRoute: BusRoute)? {
        guard !isNavigating else { return nil }
        isNavigating = true

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            isNavigating = false
        }

        return (busStop, busRoute)
    }

    // MARK: - 비공개 헬퍼 메서드

    private func handleArrivalUpdate(_ update: BusArrivalUpdate) {
        isLoading = false

        // 이전 상태를 초기화합니다.
        routeWithArrival = nil
        busLocationInfo = nil

        switch update {
        case let .arrival(arrival):
            errorMessage = nil
            routeWithArrival = BusRouteWithArrival(route: busRoute, arrival: arrival)
            currentEstimatedArrivalTime = arrival.estimatedArrivalTime

            // 2번째 전 정류장 출발 조건 체크 및 Haptic 피드백
            checkAndTriggerHapticFeedback(arrival: arrival)

            startCountdownTimer()
        case let .location(location):
            errorMessage = nil
            busLocationInfo = location
            currentEstimatedArrivalTime = nil
            stopCountdownTimer()
            // 위치 정보만 있을 때는 플래그 초기화
            hasVibratedAtSecondStop = false
        case .empty:
            errorMessage = String(localized: "bus.arrival.noOperatingRoutes")
            currentEstimatedArrivalTime = nil
            stopCountdownTimer()
            hasVibratedAtSecondStop = false
        case let .error(error):
            errorMessage = String(
                format: String(localized: "bus.arrival.error.loadFailed"),
                error.localizedDescription
            )
            currentEstimatedArrivalTime = nil
            stopCountdownTimer()
            hasVibratedAtSecondStop = false
        }
    }

    private func checkAndTriggerHapticFeedback(arrival: BusArrival) {
        // 이미 진동을 울렸다면 중복 방지
        guard !hasVibratedAtSecondStop else { return }

        // 2번째 전 정류장 출발 조건: remainingStopCount == 2
        guard let remainingStops = arrival.remainingStopCount,
              remainingStops <= 2
        else {
            return
        }

        print("✅ 2번째 전 정류장 출발 감지 - Haptic 피드백 실행")
        hasVibratedAtSecondStop = true

        // Haptic 피드백 실행 (메인 스레드 보장됨)
        hapticManager.playHaptic(intensity: 1.0, sharpness: 1.0, duration: 0.3)
    }

    private func startCountdownTimer() {
        stopCountdownTimer()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func stopCountdownTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }

    private func tick() {
        guard var estimatedTime = currentEstimatedArrivalTime else {
            stopCountdownTimer()
            return
        }

        if estimatedTime > 0 {
            estimatedTime -= 1
            currentEstimatedArrivalTime = estimatedTime
        } else {
            stopCountdownTimer()
            startMonitoring() // 타이머가 0이 되면 데이터를 새로고침합니다.
        }
    }
}
