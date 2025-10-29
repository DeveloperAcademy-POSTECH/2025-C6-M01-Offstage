import BusAPI
import Combine
import CoreLocation
import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    // MARK: - State

    enum ViewState {
        case idle
        case loading
        case success([BusStopForSearch])
        case error(Error)
    }

    @Published var viewState: ViewState = .idle
    @Published var searchTerm: String = ""

    // MARK: - Properties

    private var searchTask: Task<Void, Never>?
    private var destinationInputs: [UUID: BusStationViewInput] = [:]
    var nearbyStopsCache: [BusStopForSearch] = []

    // MARK: - Dependencies

    private let busRepository: BusRepository // For real-time data
    private let localBusStopRepository: LocalBusStopRepository // For local search
    private let locationManager: LocationProviding
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(busRepository: BusRepository, locationManager: LocationProviding) {
        self.busRepository = busRepository
        self.locationManager = locationManager
        do {
            localBusStopRepository = try LocalBusStopRepository()
        } catch {
            fatalError("Could not initialize LocalBusStopRepository: \(error)")
        }

        // Subscribe to search term changes
        $searchTerm
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] term in
                self?.performSearch(keyword: term)
            }
            .store(in: &cancellables)

        // Perform an initial nearby search
        performSearch(keyword: "")
    }

    // MARK: - Public Methods

    func submitSearch() {
        performSearch(keyword: searchTerm)
    }

    func destinationInput(for busStop: BusStopForSearch) -> BusStationViewInput? {
        destinationInputs[busStop.id]
    }

    // MARK: - Private Search Logic

    private func performSearch(keyword: String) {
        let trimmedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedKeyword.isEmpty {
            // If search term is empty, show nearby stops
            // Use cache if available, otherwise fetch new data
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
            let stops = try await localBusStopRepository.findNearbyStops(
                latitude: location.latitude,
                longitude: location.longitude,
                radiusInMeters: 500,
                page: 1, // Fetch first page only
                pageSize: 20 // Get up to 20 stops
            )

            let presentations = processStops(stops, with: location.asCLLocation)
            let (displayStops, inputs) = await makeDisplayStops(from: presentations)

            destinationInputs = inputs
            nearbyStopsCache = displayStops // Cache the nearby results
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
                let stops = try await localBusStopRepository.searchStops(
                    byName: keyword,
                    page: 1, // Fetch first page only
                    pageSize: 50 // Get up to 50 results
                )
                let presentations = processStops(stops, with: nil) // No location for name search
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
        -> ([BusStopForSearch], [UUID: BusStationViewInput])
    {
        guard !stops.isEmpty else { return ([], [:]) }

        return await withTaskGroup(
            of: (BusStopForSearch, BusStationViewInput?).self,
            returning: ([BusStopForSearch], [UUID: BusStationViewInput]).self
        ) { group in
            for entry in stops {
                group.addTask {
                    let routes = try? await self.busRepository
                        .fetchRoutesPassingThroughStop(
                            cityCode: String(entry.stop.cityCode ?? 0),
                            nodeId: entry.stop.nodeId
                        )
                        .map(\.routeNumber)
                        .sorted()

                    let identifier = UUID()
                    let result = BusStopForSearch(
                        id: identifier,
                        nodenm: entry.stop.name,
                        nodeno: entry.stop.number,
                        routes: routes ?? [],
                        distance: entry.distance
                    )

                    let input = BusStationViewInput(
                        cityCode: String(entry.stop.cityCode ?? 0),
                        nodeId: entry.stop.nodeId,
                        nodeName: entry.stop.name,
                        nodeNumber: entry.stop.number,
                        routes: routes ?? []
                    )
                    return (result, input)
                }
            }

            var results: [BusStopForSearch] = []
            var inputs: [UUID: BusStationViewInput] = [:]
            for await (stop, input) in group {
                results.append(stop)
                if let input {
                    inputs[stop.id] = input
                }
            }
            return (results, inputs)
        }
    }
}

// MARK: - Helpers

private extension SearchViewModel {
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
