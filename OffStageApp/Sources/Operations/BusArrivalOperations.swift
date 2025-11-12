import BusAPI
import CoreLocation
import Foundation

// 도착 정보 조회 시 발생할 수 있는 결과들을 나타내는 열거형입니다.
enum BusArrivalUpdate {
    case arrival(BusArrival)
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

    // 초기 데이터를 제공하고 30초마다 주기적으로 업데이트하는 스트림을 생성합니다.
    func monitorArrivals(busStop: BusStop, busRoute: BusRoute) -> AsyncStream<BusArrivalUpdate> {
        AsyncStream { continuation in
            let task = Task {
                // 조회를 수행하고 결과를 전달하는 헬퍼 함수입니다.
                func fetchAndYield() async {
                    do {
                        let arrivals = try await fetchArrivalsOnly(busStop: busStop, busRoute: busRoute)
                        if let firstArrival = arrivals.first {
                            continuation.yield(.arrival(firstArrival))
                        } else {
                            let locations = try await fetchLocations(busStop: busStop, busRoute: busRoute)
                            if let firstLocation = locations.first {
                                continuation.yield(.location(firstLocation))
                            } else {
                                continuation.yield(.empty)
                            }
                        }
                    } catch {
                        continuation.yield(.error(error))
                    }
                }

                // 즉시 초기 조회를 수행합니다.
                await fetchAndYield()

                // 주기적인 새로고침을 예약합니다.
                while !Task.isCancelled {
                    do {
                        // 다음 새로고침 전 30초 동안 대기합니다.
                        try await Task.sleep(nanoseconds: 30 * 1_000_000_000)
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

    private func fetchArrivalsOnly(busStop: BusStop, busRoute: BusRoute) async throws -> [BusArrival] {
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
