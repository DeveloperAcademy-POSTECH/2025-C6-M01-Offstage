import BusAPI
import CoreLocation
import Foundation

// 도착 정보 조회 시 발생할 수 있는 결과들을 나타내는 열거형입니다.
enum BusArrivalUpdate {
    case arrival(BusArrival, BusUrgencyStatus) // 긴급도 상태 포함
    case location(BusLocation)
    case error(Error)
    case empty
}

// Operations 계층 패턴에 따라 버스 도착 정보 조회 및 모니터링을 위한 비즈니스 로직을 캡슐화한 클래스입니다.
final class BusArrivalOperations {
    private let busRepository: BusRepository
    private let locationProvider: LocationProviding

    init(
        busRepository: BusRepository = MainBusRepository(),
        locationProvider: LocationProviding = LocationManager()
    ) {
        self.busRepository = busRepository
        self.locationProvider = locationProvider
    }

    // 초기 데이터를 제공하고, 도착 예정 시간에 따라 동적으로 결정된 간격으로 주기적 업데이트를 제공하는 스트림을 생성합니다.
    func monitorArrivals(busStop: BusStop, busRoute: BusRoute) -> AsyncStream<BusArrivalUpdate> {
        AsyncStream { continuation in
            var lastUrgencyStatus: BusUrgencyStatus = .notApplicable // 마지막 긴급도 상태를 저장

            let task = Task {
                // 조회를 수행하고 결과를 전달하는 헬퍼 함수입니다.
                func fetchAndYield() async {
                    do {
                        let arrivals = try await fetchArrivalsOnly(busStop: busStop, busRoute: busRoute)
                        if let firstArrival = arrivals.first {
                            // 도착 정보를 기반으로 긴급도 상태를 계산합니다.
                            let status = calculateBusUrgencyStatus(for: firstArrival)
                            lastUrgencyStatus = status // 긴급도 상태 업데이트
                            continuation.yield(.arrival(firstArrival, status))
                        } else {
                            lastUrgencyStatus = .notApplicable // 도착 정보 없으므로 초기화
                            let locations = try await fetchLocations(busStop: busStop, busRoute: busRoute)
                            if let firstLocation = locations.first {
                                continuation.yield(.location(firstLocation))
                            } else {
                                continuation.yield(.empty)
                            }
                        }
                    } catch {
                        lastUrgencyStatus = .notApplicable // 에러 발생 시 초기화
                        continuation.yield(.error(error))
                    }
                }

                // 즉시 초기 조회를 수행합니다.
                await fetchAndYield()

                // 주기적인 새로고침을 예약합니다.
                while !Task.isCancelled {
                    // 마지막 긴급도 상태를 기준으로 다음 새로고침 간격을 계산합니다.
                    let interval = lastUrgencyStatus.refreshIntervalSeconds * 1_000_000_000

                    do {
                        try await Task.sleep(nanoseconds: interval)
                    } catch {
                        // 대기 중 작업이 취소되면 루프를 종료합니다.
                        break
                    }

                    if Task.isCancelled { break }

                    await fetchAndYield()
                }
            }

            // 스트림이 취소되면 내부 작업을 취소합니다.
            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }

    /// 버스 도착 정보에 따라 긴급도 상태를 계산합니다.
    private func calculateBusUrgencyStatus(for arrivalInfo: BusArrival) -> BusUrgencyStatus {
        BusUrgencyStatus.status(
            for: arrivalInfo.estimatedArrivalTime,
            remainingStops: arrivalInfo.remainingStopCount
        )
    }

    /// BusVisionArrivalAlertManager에서 사용할 수 있도록 public 메서드 제공
    func fetchArrivalsOnly(busStop: BusStop, busRoute: BusRoute) async throws -> [BusArrival] {
        let cityCode = try await detectCityCode(from: CLLocationCoordinate2D(
            latitude: busStop.latitude,
            longitude: busStop.longitude
        ))
        return try await busRepository.fetchRouteArrivals(
            cityCode: cityCode,
            nodeId: busStop.nodeId,
            routeId: busRoute.routeId
        )
    }

    private func fetchLocations(busStop: BusStop, busRoute: BusRoute) async throws -> [BusLocation] {
        let cityCode = try await detectCityCode(from: CLLocationCoordinate2D(
            latitude: busStop.latitude,
            longitude: busStop.longitude
        ))
        return try await busRepository.fetchRouteLocations(
            cityCode: cityCode,
            routeId: busRoute.routeId,
            page: nil
        )
    }

    private func detectCityCode(from gps: CLLocationCoordinate2D) async throws -> String {
        guard let placemark = try await locationProvider.fetchPlacemark(from: gps) else {
            throw BusAPIError.unknown("Failed to fetch placemark for city code detection.")
        }
        return CityCodeConverter.findCode(from: placemark) ?? "31020" // Default to Seongnam
    }
}
