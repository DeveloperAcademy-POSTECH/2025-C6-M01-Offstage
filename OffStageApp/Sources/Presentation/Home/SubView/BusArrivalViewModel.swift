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

    // MARK: - 속성

    let busStop: BusStop
    let busRoute: BusRoute
    private let busArrivalOperations: BusArrivalOperations
    private var arrivalMonitoringTask: Task<Void, Never>?
    private var countdownTimer: Timer?

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
            startCountdownTimer()
        case let .location(location):
            errorMessage = nil
            busLocationInfo = location
            currentEstimatedArrivalTime = nil
            stopCountdownTimer()
        case .empty:
            errorMessage = String(localized: "bus.arrival.noOperatingRoutes")
            currentEstimatedArrivalTime = nil
            stopCountdownTimer()
        case let .error(error):
            errorMessage = String(
                format: String(localized: "bus.arrival.error.loadFailed"),
                error.localizedDescription
            )
            currentEstimatedArrivalTime = nil
            stopCountdownTimer()
        }
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
