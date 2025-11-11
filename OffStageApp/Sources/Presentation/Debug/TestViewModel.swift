import BusAPI
import Combine
import Foundation
import Logging

struct DTOSection: Identifiable {
    struct Item: Identifiable {
        let id = UUID()
        let name: String
        let value: String
    }

    let id = UUID()
    let title: String
    let items: [Item]
}

@MainActor
final class TestViewModel: ObservableObject {
    @Published var resultText: String = "API 응답이 이 영역에 표시됩니다."
    @Published var isLoading = false
    @Published var displaySections: [DTOSection]?
    @Published var rawResponseText: String?

    // Properties for text fields
    @Published var cityCode: String = "1000"
    @Published var nodeId: String = "100000001"
    @Published var routeId: String = "100100006"
    @Published var stopName: String = "서울역"
    @Published var routeNo: String = "100"
    @Published var gpsLati: String = "37.555946"
    @Published var gpsLong: String = "126.972317"

    private let locationProvider: LocationProviding
    private let busRepository: BusRepository
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(label: "TestViewModel")

    init(
        locationProvider: LocationProviding = LocationManager(),
        busRepository: BusRepository = MainBusRepository()
    ) {
        self.locationProvider = locationProvider
        self.busRepository = busRepository
    }

    func onAppear() {
        subscribeLocation()
    }

    func resetApiDisplay() {
        displaySections = nil
        rawResponseText = nil
        resultText = "API 응답이 이 영역에 표시됩니다."
    }

    func searchStop() async {
        logger.info("searchStop() called")
        await performRequest(
            name: "Stop search"
        ) {
            try await busRepository.searchStops(
                cityCode: self.cityCode,
                keyword: self.stopName
            )
        } onSuccess: { [weak self] stops in
            guard let self else { return }
            updateDisplay(with: stops, title: "정류장", describe: describeStops, emptyMessage: "정류장 정보를 찾을 수 없습니다.")
        }
    }

    func getArrivals() async {
        logger.info("getArrivals() called")
        await performRequest(
            name: "Stop arrivals"
        ) {
            try await busRepository.fetchStopArrivals(
                cityCode: self.cityCode,
                nodeId: self.nodeId
            )
        } onSuccess: { [weak self] arrivals in
            guard let self else { return }
            updateDisplay(with: arrivals, title: "도착 정보", describe: describeArrivals, emptyMessage: "도착 예정 정보가 없습니다.")
        }
    }

    func getArrivalsForRoute() async {
        logger.info("getArrivalsForRoute() called")
        await performRequest(
            name: "Route-specific arrivals"
        ) {
            try await busRepository.fetchRouteArrivals(
                cityCode: self.cityCode,
                nodeId: self.nodeId,
                routeId: self.routeId
            )
        } onSuccess: { [weak self] arrivals in
            guard let self else { return }
            updateDisplay(with: arrivals, title: "도착 정보", describe: describeArrivals, emptyMessage: "도착 예정 정보가 없습니다.")
        }
    }

    func getRouteBusLocations() async {
        logger.info("getRouteBusLocations() called")
        await performRequest(
            name: "Route vehicle locations"
        ) {
            try await busRepository.fetchRouteLocations(
                cityCode: self.cityCode,
                routeId: self.routeId,
                page: nil
            )
        } onSuccess: { [weak self] locations in
            guard let self else { return }
            updateDisplay(
                with: locations,
                title: "차량 위치",
                describe: describeLocations,
                emptyMessage: "차량 위치 정보를 찾을 수 없습니다."
            )
        }
    }

    func getStopsByGPS() async {
        logger.info("getStopsByGPS() called")
        await performRequest(
            name: "Nearby stops"
        ) {
            guard let lat = Double(self.gpsLati), let lon = Double(self.gpsLong) else {
                throw BusAPIError.unknown("Invalid GPS coordinates in text fields.")
            }
            return try await busRepository.fetchStopsNearby(
                latitude: lat,
                longitude: lon,
                cityCode: self.cityCode
            )
        } onSuccess: { [weak self] stops in
            guard let self else { return }
            updateDisplay(with: stops, title: "정류장", describe: describeStops, emptyMessage: "정류장 정보를 찾을 수 없습니다.")
        }
    }

    func getStopRoutes() async {
        logger.info("getStopRoutes() called")
        await performRequest(
            name: "Routes by stop"
        ) {
            try await busRepository.fetchRoutesPassingThroughStop(
                cityCode: self.cityCode,
                nodeId: self.nodeId
            )
        } onSuccess: { [weak self] routes in
            guard let self else { return }
            updateDisplay(with: routes, title: "노선", describe: describeRoutes, emptyMessage: "노선 정보를 찾을 수 없습니다.")
        }
    }

    func getRouteInfo() async {
        logger.info("getRouteInfo() called")
        await performRequest(
            name: "Route info"
        ) {
            try await busRepository.fetchRouteInfo(
                cityCode: self.cityCode,
                routeId: self.routeId
            )
        } onSuccess: { [weak self] route in
            guard let self else { return }
            let routes = route.map { [$0] } ?? []
            updateDisplay(
                with: routes,
                title: "노선",
                describe: { describeRoute($0.first) },
                emptyMessage: "노선 정보를 찾을 수 없습니다."
            )
        }
    }

    func searchRoute() async {
        logger.info("searchRoute() called")
        await performRequest(
            name: "Route number search"
        ) {
            try await busRepository.searchRoutes(
                cityCode: self.cityCode,
                routeNumber: self.routeNo
            )
        } onSuccess: { [weak self] routes in
            guard let self else { return }
            updateDisplay(with: routes, title: "노선", describe: describeRoutes, emptyMessage: "노선 정보를 찾을 수 없습니다.")
        }
    }

    // MARK: - Seoul API Tests

    func testSeoulGpsSearch() async {
        logger.info("testSeoulGpsSearch() called")
        await performRequest(
            name: "Seoul GPS search"
        ) {
            // [수정] busStopInfo 대신 서울 시청 좌표와 "1000" 코드를 하드코딩합니다.
            let seoulLatitude = 37.5665 // 서울 시청 위도
            let seoulLongitude = 126.9780 // 서울 시청 경도

            return try await busRepository.fetchStopsNearby(
                latitude: seoulLatitude,
                longitude: seoulLongitude,
                cityCode: "1000" // "1000"을 명시
            )
        } onSuccess: { [weak self] stops in
            guard let self else { return }
            updateDisplay(
                with: stops,
                title: "서울 GPS 검색 정류장 (시청 근처)",
                describe: describeStops,
                emptyMessage: "서울 GPS 검색으로 정류장을 찾을 수 없습니다."
            )
        }
    }

    func testSeoulKeywordSearch() async {
        logger.info("testSeoulKeywordSearch() called")
        await performRequest(
            name: "Seoul keyword search"
        ) {
            // [수정] busStopInfo.cityCode 대신 "1000" 코드를 하드코딩합니다.
            try await busRepository.searchStops(
                cityCode: "1000", // "1000"을 명시
                nodeName: "서울역",
                nodeNumber: nil
            )
        } onSuccess: { [weak self] stops in
            guard let self else { return }
            updateDisplay(
                with: stops,
                title: "서울 키워드 '서울역' 검색 정류장",
                describe: describeStops,
                emptyMessage: "서울 키워드 검색으로 정류장을 찾을 수 없습니다."
            )
        }
    }

    func testSeoulStopDetail() async {
        logger.info("testSeoulStopDetail() called")

        // [수정] busStopInfo 대신 서울역 'arsId'와 "1000" 코드를 하드코딩합니다.
        let seoulArsId = "02005" // 서울역 버스환승센터(6) 정류소 arsId
        let cityCode = "1000"

        await performRequest(
            name: "Seoul stop detail (서울역)"
        ) {
            // BusStationViewModel과 동일한 로직:
            // 1. fetchRoutesPassingThroughStop 호출
            let routes = try await busRepository.fetchRoutesPassingThroughStop(
                cityCode: cityCode,
                nodeId: seoulArsId // nodeId 파라미터에 arsId 전달
            )
            // 2. fetchStopArrivals 호출
            let arrivals = try await busRepository.fetchStopArrivals(
                cityCode: cityCode,
                nodeId: seoulArsId // nodeId 파라미터에 arsId 전달
            )
            return (arrivals, routes) // Tuple로 반환하여 한 번에 처리
        } onSuccess: { [weak self] (arrivals: [BusArrival], routes: [BusRoute]) in
            guard let self else { return }

            // 도착 정보 표시 업데이트
            updateDisplay(
                with: arrivals,
                title: "서울 정류소 도착 정보 (arsId: \(seoulArsId))",
                describe: describeArrivals,
                emptyMessage: "서울 정류소 도착 예정 정보가 없습니다."
            )

            // 노선 정보 표시 업데이트 (기존 arrival 정보에 추가)
            if !routes.isEmpty {
                let routeSections = makeSections(from: routes, title: "서울 정류소 노선 정보")
                if displaySections == nil {
                    displaySections = routeSections
                } else {
                    displaySections?.append(contentsOf: routeSections)
                }
                let routeDescription = describeRoutes(routes)
                if resultText.contains("API 응답이 이 영역에 표시됩니다.") || resultText.contains("예정 정보가 없습니다.") {
                    resultText = routeDescription
                } else {
                    resultText += "\n" + routeDescription
                }
            } else {
                if resultText.contains("API 응답이 이 영역에 표시됩니다.") || resultText.contains("예정 정보가 없습니다.") {
                    resultText = "서울 정류소 노선 정보를 찾을 수 없습니다."
                } else {
                    resultText += "\n" + resultText
                }
            }
        }
    }

    func getRouteStops() async {
        logger.info("getRouteStops() called")
        await performRequest(
            name: "Route stations"
        ) {
            try await busRepository.fetchRouteStations(
                cityCode: self.cityCode,
                routeId: self.routeId
            )
        } onSuccess: { [weak self] stations in
            guard let self else { return }
            updateDisplay(
                with: stations,
                title: "경유 정류장",
                describe: describeStations,
                emptyMessage: "경유 정류장 정보를 찾을 수 없습니다."
            )
        }
    }

    func testSeoulRouteStations() async {
        logger.info("testSeoulRouteStations() called")
        await performRequest(
            name: "Seoul Route Stations"
        ) {
            try await self.busRepository.fetchRouteStations(
                cityCode: "1000",
                routeId: self.routeId
            )
        } onSuccess: { [weak self] stations in
            guard let self else { return }
            updateDisplay(
                with: stations,
                title: "서울 노선 경유 정류장",
                describe: describeStations,
                emptyMessage: "경유 정류장 정보 없음"
            )
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

    private func performRequest<Result>(
        name: String,
        operation: () async throws -> Result,
        onSuccess: (Result) -> Void
    ) async {
        isLoading = true
        resultText = "불러오는 중..."
        displaySections = nil
        rawResponseText = nil
        do {
            let result = try await operation()
            onSuccess(result)
            logger.info("\(name) 성공")
        } catch {
            handle(error: error, for: name)
        }
        isLoading = false
    }

    private func handle(error: Error, for name: String) {
        rawResponseText = nil
        if let busError = error as? BusAPIError {
            resultText = "버스 API 오류: \(busError.localizedDescription)"
        } else {
            resultText = "오류가 발생했습니다: \(error.localizedDescription)"
        }
        logger.error("\(name) 실패: \(error.localizedDescription)")
    }

    private func detectCityCode(from gps: GpsInfo) async throws -> String {
        let locationCoordinate = LocationCoordinate(latitude: gps.latitude, longitude: gps.longitude)
        guard let placemark = try await locationProvider.fetchPlacemark(from: locationCoordinate) else {
            throw BusAPIError.unknown("Failed to fetch placemark for city code detection.")
        }
        // CityCodeConverter is in BusAPI module, but it should be fine as it has no external dependencies
        let detectedCityCode = CityCodeConverter.findCode(from: placemark) ?? "31020" // Default to Seongnam
        return detectedCityCode
    }

    private func describeStops(_ stops: [BusStop]) -> String {
        guard let first = stops.first else {
            return "정류장 정보를 찾을 수 없습니다."
        }
        return "총 \(stops.count)개의 정류장을 받았습니다. 첫 번째 정류장: \(first.name) (\(first.nodeId))"
    }

    private func describeRoutes(_ routes: [BusRoute]) -> String {
        guard let first = routes.first else {
            return "노선 정보를 찾을 수 없습니다."
        }
        return "총 \(routes.count)개의 노선 정보를 받았습니다. 첫 번째 노선: \(first.routeNumber) (\(first.startStopName) → \(first.endStopName))"
    }

    private func describeRoute(_ route: BusRoute?) -> String {
        guard let route else {
            return "노선 정보를 찾을 수 없습니다."
        }
        return "\(route.routeNumber) (\(route.startStopName) → \(route.endStopName))"
    }

    private func describeStations(_ stations: [BusRouteStation]) -> String {
        guard let first = stations.first else {
            return "경유 정류장 정보를 찾을 수 없습니다."
        }
        return "총 \(stations.count)개의 경유 정류장을 받았습니다. 첫 번째: #\(first.stationOrder) \(first.stationName)"
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

    private func describeCities(_ cities: [BusCity]) -> String {
        guard let first = cities.first else {
            return "도시 코드 정보를 찾을 수 없습니다."
        }
        return "총 \(cities.count)개의 도시 코드를 받았습니다. 첫 번째: \(first.name) (\(first.code))"
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
