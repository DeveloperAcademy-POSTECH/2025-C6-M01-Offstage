import BusAPI
import Combine
import Foundation
import Logging

@MainActor
final class MVPTestViewModel: ObservableObject {
    @Published var resultText: String = "API 응답이 이 영역에 표시됩니다."
    @Published var isLoading = false
    @Published var displaySections: [DTOSection]?
    @Published var rawResponseText: String?
    @Published var routeQuery: String = "441"

    // Location properties
    @Published var gpsLati: String = ""
    @Published var gpsLong: String = ""

    private let locationProvider: LocationProviding
    private let busRepository: BusRepository
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(label: "MVPTestViewModel")

    init(
        locationProvider: LocationProviding = LocationManager(),
        busRepository: BusRepository = MainBusRepository()
    ) {
        self.locationProvider = locationProvider
        self.busRepository = busRepository
    }

    struct GpsInfo {
        let latitude: Double
        let longitude: Double
    }

    /// MVP 시나리오의 결과를 나타내는 열거형
    enum MVPResult {
        /// 도착 정보가 있는 경우
        case arrivals([BusArrival])
        /// 도착 정보는 없지만 버스 위치 정보는 있는 경우 (Fallback)
        case locations([BusLocation])
        /// 운행 중인 버스가 없는 경우
        case noInfo
        /// 오류가 발생한 경우
        case error(Error)
    }

    func onAppear() {
        subscribeLocation()
    }

    func resetApiDisplay() {
        displaySections = nil
        rawResponseText = nil
        resultText = "API 응답이 이 영역에 표시됩니다."
    }

    func fetchNearbyStops() async -> [BusStop]? {
        isLoading = true
        defer { isLoading = false }

        guard let lat = Double(gpsLati), let lon = Double(gpsLong) else {
            resultText = "유효하지 않은 GPS 좌표입니다."
            return nil
        }

        do {
            let cityCodeString = try await detectCityCode(from: GpsInfo(latitude: lat, longitude: lon))
            let stops = try await busRepository.fetchStopsNearby(
                latitude: lat,
                longitude: lon,
                cityCode: cityCodeString
            )
            return stops
        } catch {
            handle(error: error, for: "Fetch Nearby Stops")
            return nil
        }
    }

    func findBusFor(stop: BusStop, routeQuery: String) async {
        logger.info("findBusFor(stop: \(stop.name), routeQuery: \(routeQuery)) called")
        isLoading = true
        defer { isLoading = false }

        resultText = "불러오는 중..."
        displaySections = nil
        rawResponseText = nil

        let gpsInfo = GpsInfo(latitude: stop.latitude, longitude: stop.longitude)

        do {
            let cityCodeString = try await detectCityCode(from: gpsInfo)
            guard let cityCode = Int(cityCodeString) else {
                resultText = "유효하지 않은 cityCode를 받았습니다: \(cityCodeString)"
                return
            }

            let result = await fetchMVPBusInfo(gps: gpsInfo, cityCode: cityCode, routeQuery: routeQuery)

            switch result {
            case let .arrivals(arrivals):
                updateDisplay(
                    with: arrivals,
                    title: "도착 정보 (MVP)",
                    describe: describeArrivals,
                    emptyMessage: "도착 예정 정보가 없습니다."
                )
                if !arrivals.isEmpty {
                    resultText = "곧도착 정보가 있습니다.\n" + resultText
                }
                logger.info("MVP Flow 성공: 도착 정보 수신")

            case let .locations(locations):
                updateDisplay(
                    with: locations,
                    title: "차량 위치 (MVP Fallback)",
                    describe: describeLocations,
                    emptyMessage: "차량 위치 정보를 찾을 수 없습니다."
                )
                if !locations.isEmpty {
                    let existingResult = resultText
                    resultText = "도착 예정 정보가 없습니다. 실시간 버스 위치 정보를 확인하세요.\n" + existingResult
                } else {
                    resultText = "도착 예정 정보가 없으며, 실시간 버스 위치 정보도 찾을 수 없습니다."
                }
                logger.info("MVP Flow 성공: Fallback 위치 정보 수신")

            case .noInfo:
                resultText = "현재 운행 중인 버스가 없거나, 운행이 종료된 것으로 보입니다."
                logger.info("MVP Flow 결과 없음: 현재 운행중인 버스가 없습니다.")

            case let .error(error):
                handle(error: error, for: "MVP Flow")
            }
        } catch {
            handle(error: error, for: "MVP Flow CityCode Detection")
        }
    }

    private func subscribeLocation() {
        guard cancellables.isEmpty else { return }
        locationProvider.requestLocationPermission()

        locationProvider.currentLocation
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.logger.error("Location error: \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] coordinate in
                guard let self else { return }
                gpsLati = String(coordinate.latitude)
                gpsLong = String(coordinate.longitude)
            }
            .store(in: &cancellables)
    }

    private func handle(error: Error, for name: String) {
        rawResponseText = nil
        if let busError = error as? BusAPIError {
            if case .noResults = busError {
                resultText = "해당 정류장에서 입력하신 노선을 찾을 수 없습니다."
            } else {
                resultText = "버스 API 오류: \(busError.localizedDescription)"
            }
        } else {
            resultText = "오류가 발생했습니다: \(error.localizedDescription)"
        }
        logger.error("\(name) 실패: \(error.localizedDescription)")
    }

    private func fetchMVPBusInfo(
        gps: GpsInfo,
        cityCode: Int,
        routeQuery: String
    ) async -> MVPResult {
        let cityCodeString = String(cityCode)
        let isSeoul = cityCodeString == "1000"

        do {
            // 1. GPS로 정류소 식별
            guard let stop = try await busRepository.fetchStopsNearby(
                latitude: gps.latitude,
                longitude: gps.longitude,
                cityCode: cityCodeString
            ).first else {
                return .error(BusAPIError.noResults)
            }

            // 2. 노선 맵핑 (RouteID 확보)
            let routes = try await busRepository.fetchRoutesPassingThroughStop(
                cityCode: cityCodeString,
                nodeId: stop.nodeId
            )
            guard let route = routes.first(where: { $0.routeNumber.contains(routeQuery) }) else {
                return .error(BusAPIError.noResults)
            }

            // 3. 특정 정류소-노선 도착 정보 조회
            let arrivals = try await busRepository.fetchRouteArrivals(
                cityCode: cityCodeString,
                nodeId: stop.nodeId,
                routeId: route.routeId
            )

            if !arrivals.isEmpty {
                return .arrivals(arrivals)
            } else {
                // 4. (Fallback) 노선 위치 조회
                let locations = try await busRepository.fetchRouteLocations(
                    cityCode: cityCodeString,
                    routeId: route.routeId,
                    page: nil
                )
                return locations.isEmpty ? .noInfo : .locations(locations)
            }
        } catch {
            return .error(error)
        }
    }

    private func detectCityCode(from gps: GpsInfo) async throws -> String {
        let locationCoordinate = LocationCoordinate(latitude: gps.latitude, longitude: gps.longitude)
        guard let placemark = try await locationProvider.fetchPlacemark(from: locationCoordinate) else {
            throw BusAPIError.unknown("Failed to fetch placemark for city code detection.")
        }
        let detectedCityCode = CityCodeConverter.findCode(from: placemark) ?? "31020" // Default to Seongnam
        return detectedCityCode
    }

    private func describeArrivals(_ arrivals: [BusArrival]) -> String {
        guard let first = arrivals.first else {
            return "도착 예정 정보가 없습니다."
        }
        let remaining = first.remainingStopCount.map { "남은 정류장 \($0)개" } ?? "남은 정류장 정보 없음"
        let eta = first.estimatedArrivalTime.map { "예상 도착 \($0)초" } ?? "예상 도착 정보 없음"
        return "총 \(arrivals.count)개의 도착 정보를 받았습니다. 첫 번째: \(first.routeNumber) - \(remaining), \(eta)"
    }

    private func describeLocations(_ locations: [BusLocation]) -> String {
        guard let first = locations.first else {
            return "차량 위치 정보를 찾을 수 없습니다."
        }
        return "총 \(locations.count)대 차량 위치를 받았습니다. 첫 번째 차량: \(first.nodeName) 인근 (\(first.latitude), \(first.longitude))"
    }

    private func makeSections(from items: [some Any], title: String) -> [DTOSection] {
        items.enumerated().map { index, element in
            DTOSection(
                title: "\(title) \(index + 1)번",
                items: makeItems(from: element)
            )
        }
    }

    private func makeItems(from value: Any) -> [DTOSection.Item] {
        Mirror(reflecting: value).children.compactMap { child in
            guard let label = child.label else { return nil }
            let formattedValue = formatValue(child.value)
            return DTOSection.Item(name: label, value: formattedValue)
        }
    }

    private func formatValue(_ value: Any) -> String {
        if let unwrapped = unwrapOptional(value) {
            if let describable = unwrapped as? CustomStringConvertible {
                return describable.description
            }
            return "\(unwrapped)"
        } else {
            return "nil"
        }
    }

    private func unwrapOptional(_ value: Any) -> Any? {
        let mirror = Mirror(reflecting: value)
        guard mirror.displayStyle == .optional else {
            return value
        }
        return mirror.children.first?.value
    }

    private func rawDump(_ value: some Any) -> String {
        var output = ""
        dump(value, to: &output)
        return output
    }

    private func updateDisplay<T>(
        with items: [T],
        title: String,
        describe: ([T]) -> String,
        emptyMessage: String
    ) {
        guard !items.isEmpty else {
            displaySections = nil
            rawResponseText = nil
            resultText = emptyMessage
            return
        }

        displaySections = makeSections(from: items, title: title)
        rawResponseText = rawDump(items)
        resultText = describe(items)
    }
}
