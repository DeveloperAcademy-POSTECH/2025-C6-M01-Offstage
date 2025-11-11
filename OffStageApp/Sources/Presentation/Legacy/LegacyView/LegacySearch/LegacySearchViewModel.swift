import BusAPI
import Combine
import CoreLocation
import Foundation
import SwiftUI

@MainActor
final class LegacySearchViewModel: ObservableObject {
    // MARK: - State

    enum ViewState {
        case idle
        case loading
        case success([LegacyBusStopForSearch])
        case error(Error)
    }

    @Published var viewState: ViewState = .idle
    @Published var searchTerm: String = ""
    @Published private(set) var currentCityCode: String?

    // MARK: - Properties

    private var searchTask: Task<Void, Never>?
    private var destinationInputs: [UUID: BusStationViewInput] = [:]
    var nearbyStopsCache: [LegacyBusStopForSearch] = []

    // MARK: - Dependencies

    private let busRepository: BusRepository // 실시간 데이터용
    private let locationManager: LocationProviding
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(busRepository: BusRepository, locationManager: LocationProviding) {
        self.busRepository = busRepository
        self.locationManager = locationManager

        // 검색어 변경 구독
        $searchTerm
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] term in
                if term.isEmpty {
                    self?.performSearch(keyword: term)
                }
            }
            .store(in: &cancellables)

        // 초기 주변 정류장 검색 수행
        performSearch(keyword: "")
    }

    // MARK: - Public Methods

    func submitSearch() {
        performSearch(keyword: searchTerm)
    }

    func destinationInput(for busStop: LegacyBusStopForSearch) -> BusStationViewInput? {
        destinationInputs[busStop.id]
    }

    // MARK: - Private Search Logic

    private func performSearch(keyword: String) {
        let trimmedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedKeyword.isEmpty {
            // 검색어가 비어 있으면 주변 정류장 표시
            // 캐시가 있으면 사용하고, 없으면 새로 가져오기
            if nearbyStopsCache.isEmpty {
                fetchNearbyStops()
            } else {
                viewState = .success(nearbyStopsCache)
            }
        } else {
            performNameSearch(keyword: trimmedKeyword)
        }
    }

    private func fetchNearbyStops() {
        viewState = .loading
        searchTask?.cancel()

        locationManager.currentLocation
            .first()
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.viewState = .error(error)
                }
            }, receiveValue: { [weak self] location in
                guard let self else { return }
                searchTask = Task {
                    await self.fetchStops(around: location)
                }
            })
            .store(in: &cancellables)
    }

    private func fetchStops(around location: LocationCoordinate) async {
        do {
            // [추가] Step 1: Reverse Geocoding으로 Placemark(주소) 가져오기
            guard let placemark = try await locationManager.fetchPlacemark(from: location) else {
                throw BusAPIError.unknown // 또는 적절한 에러
            }

            // [추가] Step 2: Placemark로 CityCode 찾기
            let detectedCityCode = CityCodeConverter
                .findCode(from: placemark) ?? "31020" // 서울이 아니면 성남시(31020)를 기본값으로 사용

            // [추가] Step 3: CityCode 저장 (Priming)
            currentCityCode = detectedCityCode
            print(
                "GPS Priming: CityCode \(detectedCityCode) 감지됨. Placemark: \(placemark.administrativeArea ?? ""), \(placemark.locality ?? ""), \(placemark.thoroughfare ?? "")"
            )

            // [수정] Step 4: 감지된 cityCode로 API 호출
            let stops = try await busRepository.fetchStopsNearby(
                latitude: location.latitude,
                longitude: location.longitude,
                cityCode: detectedCityCode // nil 대신 감지된 cityCode 전달
            )

            let presentations = processStops(stops, with: location.asCLLocation)
            let (displayStops, inputs) = await makeDisplayStops(from: presentations)

            destinationInputs = inputs
            nearbyStopsCache = displayStops // 주변 검색 결과 캐시
            viewState = .success(displayStops)
        } catch {
            if !Task.isCancelled {
                viewState = .error(error)
            }
        }
    }

    private func performNameSearch(keyword: String) {
        viewState = .loading
        searchTask?.cancel()

        searchTask = Task {
            do {
                let searchCityCode = currentCityCode // GPS로 감지된 cityCode 사용
                let stops = try await busRepository.searchStops(
                    cityCode: searchCityCode,
                    keyword: keyword
                )
                let presentations = processStops(stops, with: nil) // 이름 검색에는 위치 정보 없음
                let (displayStops, inputs) = await makeDisplayStops(from: presentations)
                self.destinationInputs = inputs
                self.viewState = .success(displayStops)
            } catch {
                if !Task.isCancelled {
                    self.viewState = .error(error)
                }
            }
        }
    }

    // MARK: - Data Processing

    private func processStops(_ stops: [BusStop], with userLocation: CLLocation?) -> [StopPresentation] {
        if let userLocation {
            stops.map { stop -> StopPresentation in
                let stopLocation = CLLocation(latitude: stop.latitude, longitude: stop.longitude)
                let distance = userLocation.distance(from: stopLocation)
                return StopPresentation(stop: stop, distance: Self.formatDistance(distance))
            }
        } else {
            stops.map { StopPresentation(stop: $0, distance: nil) }
        }
    }

    private func makeDisplayStops(from stops: [StopPresentation]) async
        -> ([LegacyBusStopForSearch], [UUID: BusStationViewInput])
    {
        guard !stops.isEmpty else { return ([], [:]) }
        let contextCityCode = currentCityCode
        return await withTaskGroup(
            of: (LegacyBusStopForSearch, BusStationViewInput?).self,
            returning: ([LegacyBusStopForSearch], [UUID: BusStationViewInput]).self
        ) { group in
            for entry in stops {
                group.addTask {
                    let cityCodeForAPI: String = if let entryCityCode = entry.stop.cityCode, entryCityCode != 0 {
                        String(entryCityCode)
                    } else {
                        contextCityCode ?? "0"
                    }

                    let routes = try? await self.busRepository
                        .fetchRoutesPassingThroughStop(
                            cityCode: cityCodeForAPI,
                            nodeId: entry.stop.nodeId
                        )
                        .map(\.routeNumber)
                        .sorted()
                    let identifier = UUID()
                    let result = LegacyBusStopForSearch(
                        id: identifier,
                        nodenm: entry.stop.name,
                        nodeno: entry.stop.number,
                        routes: routes ?? [],
                        distance: entry.distance
                    )

                    let input = BusStationViewInput(
                        cityCode: cityCodeForAPI,
                        nodeId: entry.stop.nodeId,
                        nodeName: entry.stop.name,
                        nodeNumber: entry.stop.number,
                        routes: routes ?? []
                    )
                    return (result, input)
                }
            }

            var results: [LegacyBusStopForSearch] = []
            var inputs: [UUID: BusStationViewInput] = [:]
            for await (stop, input) in group {
                results.append(stop)
                if let input {
                    inputs[stop.id] = input
                }
            }

            // 검색 유형에 따라 결과 정렬
            if stops.first?.distance != nil {
                // 주변 검색: 거리순으로 정렬
                func distanceInMeters(from distanceString: String?) -> Double {
                    guard let distanceString else { return Double.greatestFiniteMagnitude }
                    if distanceString.hasSuffix("km") {
                        let value = Double(distanceString.dropLast(2)) ?? 0.0
                        return value * 1000
                    } else if distanceString.hasSuffix("m") {
                        return Double(distanceString.dropLast(1)) ?? 0.0
                    }
                    return Double.greatestFiniteMagnitude
                }
                results.sort { distanceInMeters(from: $0.distance) < distanceInMeters(from: $1.distance) }
            } else {
                // 이름 검색: 이름순으로 정렬
                results.sort { $0.nodenm < $1.nodenm }
            }

            return (results, inputs)
        }
    }
}

// MARK: - Helpers

private extension LegacySearchViewModel {
    struct StopPresentation {
        let stop: BusStop
        let distance: String?
    }

    nonisolated static func formatDistance(_ distance: Double) -> String {
        if distance >= 1000 {
            String(format: "%.1fkm", distance / 1000)
        } else {
            String(format: "%.0fm", distance)
        }
    }
}

private extension LocationCoordinate {
    var asCLLocation: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
}
