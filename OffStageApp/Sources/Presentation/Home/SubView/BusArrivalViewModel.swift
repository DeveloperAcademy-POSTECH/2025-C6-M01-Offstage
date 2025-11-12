import BusAPI
import Combine
import CoreLocation
import Foundation

@MainActor
final class BusArrivalViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var busArrivalInfo: BusArrival?
    @Published var busLocationInfo: BusLocation?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isBusVisionButtonEnabled = false
    @Published var currentEstimatedArrivalTime: Int? {
        didSet {
            updateBusVisionButtonState()
        }
    }

    // MARK: - Properties

    let busStop: BusStop
    let busRoute: BusRoute
    private let busArrivalOperations: BusArrivalOperations
    private var arrivalMonitoringTask: Task<Void, Never>?
    private var countdownTimer: Timer?

    // MARK: - Initialization

    init(
        busStop: BusStop,
        busRoute: BusRoute,
        busArrivalOperations: BusArrivalOperations = BusArrivalOperations()
    ) {
        self.busStop = busStop
        self.busRoute = busRoute
        self.busArrivalOperations = busArrivalOperations
    }

    deinit {
        arrivalMonitoringTask?.cancel()
        countdownTimer?.invalidate()
    }

    // MARK: - Public Methods

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

    // MARK: - Private Helper Methods

    private func handleArrivalUpdate(_ update: BusArrivalUpdate) {
        isLoading = false

        // 이전 상태를 초기화합니다.
        busArrivalInfo = nil
        busLocationInfo = nil

        switch update {
        case let .arrival(arrival):
            errorMessage = nil
            busArrivalInfo = arrival
            currentEstimatedArrivalTime = arrival.estimatedArrivalTime
            startCountdownTimer()
        case let .location(location):
            errorMessage = nil
            busLocationInfo = location
            currentEstimatedArrivalTime = nil
            stopCountdownTimer()
        case .empty:
            errorMessage = "현재는 운행중인 노선이 없습니다."
            currentEstimatedArrivalTime = nil
            stopCountdownTimer()
        case let .error(error):
            errorMessage = "도착 정보를 불러오는 데 실패했습니다: \(error.localizedDescription)"
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

    private func updateBusVisionButtonState() {
        if let estimatedTime = currentEstimatedArrivalTime, estimatedTime <= 60 {
            isBusVisionButtonEnabled = true
        } else {
            isBusVisionButtonEnabled = false
        }
    }
}
