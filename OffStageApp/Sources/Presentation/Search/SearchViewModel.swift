import BusAPI
import Combine
import CoreLocation
import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    enum ViewState {
        case idle
        case loading
        case success([BusStopForSearch])
        case error(Error)
    }

    enum SearchError: LocalizedError {
        case cityCodeUnavailable

        var errorDescription: String? {
            "현재 위치의 도시 정보를 확인하지 못했습니다. 잠시 후 다시 시도해 주세요."
        }
    }

    @Published var viewState: ViewState = .idle
    @Published var searchTerm: String = ""
    @Published private(set) var nearbyStopsCache: [BusStopForSearch] = []

    private var cancellables = Set<AnyCancellable>()
    private let busRepository: BusRepository
    private let locationManager: LocationProviding
    private var lastKnownCityCode: Int?
    private var nearbyStopInputs: [UUID: BusStationViewInput] = [:]
    private var searchStopInputs: [UUID: BusStationViewInput] = [:]

    private struct StopPresentation {
        let stop: BusStop
        let distance: String?
    }

    init(busRepository: BusRepository, locationManager: LocationProviding) {
        self.busRepository = busRepository
        self.locationManager = locationManager

        $searchTerm
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] term in
                guard let self else { return }
                if term.isEmpty {
                    if nearbyStopsCache.isEmpty {
                        fetchNearbyStops()
                    } else {
                        viewState = .success(nearbyStopsCache)
                        searchStopInputs = [:]
                    }
                }
            }
            .store(in: &cancellables)

        fetchNearbyStops()
    }

    func submitSearch() {
        let trimmedKeyword = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)
        searchTerm = trimmedKeyword

        guard !trimmedKeyword.isEmpty else {
            if nearbyStopsCache.isEmpty {
                fetchNearbyStops()
            } else {
                viewState = .success(nearbyStopsCache)
                searchStopInputs = [:]
            }
            return
        }

        viewState = .loading

        Task { [weak self] in
            await self?.performStopSearch(keyword: trimmedKeyword)
        }
    }

    func fetchNearbyStops() {
        viewState = .loading

        locationManager.currentLocation
            .first()
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.viewState = .error(error)
                }
            }, receiveValue: { [weak self] location in
                guard let self else { return }

                Task {
                    await self.fetchStops(around: location)
                }
            })
            .store(in: &cancellables)
    }

    private func fetchStops(around location: LocationCoordinate) async {
        do {
            let stops = try await busRepository.fetchStopsNearby(
                latitude: location.latitude,
                longitude: location.longitude
            )

            let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)

            let orderedStops = stops.compactMap { stop -> (stop: BusStop, distance: Double, cityCode: Int)? in
                guard let cityCode = stop.cityCode else { return nil }
                let stopLocation = CLLocation(latitude: stop.latitude, longitude: stop.longitude)
                let distance = userLocation.distance(from: stopLocation)
                return (stop, distance, cityCode)
            }
            .sorted { $0.distance < $1.distance }

            let limitedStops = Array(orderedStops.prefix(5))

            if let firstCityCode = limitedStops.first?.cityCode {
                lastKnownCityCode = firstCityCode
            }

            let presentations = limitedStops.map { entry in
                StopPresentation(
                    stop: entry.stop,
                    distance: Self.formatDistance(entry.distance)
                )
            }

            let (nearbyStops, inputs) = await makeDisplayStops(from: presentations)

            nearbyStopInputs = inputs
            searchStopInputs = [:]
            nearbyStopsCache = nearbyStops
            viewState = .success(nearbyStops)
        } catch {
            viewState = .error(error)
        }
    }

    private func performStopSearch(keyword: String) async {
        guard let cityCode = lastKnownCityCode else {
            viewState = .error(SearchError.cityCodeUnavailable)
            return
        }

        do {
            let sanitizedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
            let isNumeric = sanitizedKeyword.allSatisfy(\.isNumber)
            let stops = try await busRepository.searchStops(
                cityCode: String(cityCode),
                nodeName: isNumeric ? nil : sanitizedKeyword,
                nodeNumber: isNumeric ? sanitizedKeyword : nil
            )

            if let updatedCityCode = stops.compactMap(\.cityCode).first {
                lastKnownCityCode = updatedCityCode
            }

            let presentations = stops.map { stop in
                StopPresentation(stop: stop, distance: nil)
            }

            let (searchResults, inputs) = await makeDisplayStops(
                from: presentations,
                fallbackCityCode: lastKnownCityCode
            )
            searchStopInputs = inputs
            viewState = .success(searchResults)
        } catch {
            viewState = .error(error)
        }
    }

    func destinationInput(for busStop: BusStopForSearch) -> BusStationViewInput? {
        let inputs = searchTerm.isEmpty ? nearbyStopInputs : searchStopInputs
        return inputs[busStop.id] ?? nearbyStopInputs[busStop.id]
    }

    private func makeDisplayStops(
        from stops: [StopPresentation],
        fallbackCityCode: Int? = nil
    ) async -> ([BusStopForSearch], [UUID: BusStationViewInput]) {
        guard !stops.isEmpty else { return ([], [:]) }
        let repository = busRepository

        return await withTaskGroup(
            of: (Int, BusStopForSearch?, BusStationViewInput?).self,
            returning: ([BusStopForSearch], [UUID: BusStationViewInput]).self
        ) { group in
            for (index, entry) in stops.enumerated() {
                group.addTask {
                    let resolvedCityCode = entry.stop.cityCode ?? fallbackCityCode

                    let routes: [String]
                    if let cityCode = resolvedCityCode {
                        do {
                            routes = try await repository
                                .fetchRoutesPassingThroughStop(cityCode: String(cityCode), nodeId: entry.stop.nodeId)
                                .map(\.routeNumber)
                                .sorted()
                        } catch {
                            routes = []
                        }
                    } else {
                        routes = []
                    }

                    let identifier = UUID()
                    let result = BusStopForSearch(
                        id: identifier,
                        nodenm: entry.stop.name,
                        nodeno: entry.stop.number,
                        routes: routes,
                        distance: entry.distance
                    )

                    let input: BusStationViewInput? = if let cityCode = resolvedCityCode {
                        BusStationViewInput(
                            cityCode: String(cityCode),
                            nodeId: entry.stop.nodeId,
                            nodeName: entry.stop.name,
                            nodeNumber: entry.stop.number,
                            routes: routes
                        )
                    } else {
                        nil
                    }

                    return (index, result, input)
                }
            }

            var orderedResults = [BusStopForSearch?](repeating: nil, count: stops.count)
            var inputs = [UUID: BusStationViewInput]()
            for await (index, value, input) in group {
                orderedResults[index] = value
                if let stop = value, let input {
                    inputs[stop.id] = input
                }
            }

            return (orderedResults.compactMap { $0 }, inputs)
        }
    }

    private nonisolated static func formatDistance(_ distance: Double) -> String {
        if distance >= 1000 {
            String(format: "%.1fkm", distance / 1000)
        } else {
            String(format: "%.0fm", distance)
        }
    }
}
