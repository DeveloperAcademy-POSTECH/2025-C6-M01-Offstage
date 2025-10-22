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

            let nearbyStops = await makeDisplayStops(from: presentations)

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

            let searchResults = await makeDisplayStops(from: presentations, fallbackCityCode: lastKnownCityCode)
            viewState = .success(searchResults)
        } catch {
            viewState = .error(error)
        }
    }

    private func makeDisplayStops(
        from stops: [StopPresentation],
        fallbackCityCode: Int? = nil
    ) async -> [BusStopForSearch] {
        guard !stops.isEmpty else { return [] }
        let repository = busRepository

        return await withTaskGroup(
            of: (Int, BusStopForSearch?).self,
            returning: [BusStopForSearch].self
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

                    let result = BusStopForSearch(
                        nodenm: entry.stop.name,
                        nodeid: entry.stop.nodeId,
                        routes: routes,
                        distance: entry.distance
                    )
                    return (index, result)
                }
            }

            var orderedResults = [BusStopForSearch?](repeating: nil, count: stops.count)
            for await (index, value) in group {
                orderedResults[index] = value
            }

            return orderedResults.compactMap { $0 }
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
