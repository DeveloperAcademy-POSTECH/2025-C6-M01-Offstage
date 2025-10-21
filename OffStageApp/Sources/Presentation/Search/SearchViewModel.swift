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

    @Published var viewState: ViewState = .idle
    @Published var searchTerm: String = ""

    private var cancellables = Set<AnyCancellable>()
    private let busRepository: BusRepository
    private let locationManager: LocationProviding

    init(busRepository: BusRepository, locationManager: LocationProviding) {
        self.busRepository = busRepository
        self.locationManager = locationManager

        $searchTerm
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] term in
                guard let self else { return }
                if term.isEmpty {
                    fetchNearbyStops()
                } else {
                    // TODO: Need to get cityCode from somewhere
//                    searchStops(query: term, cityCode: "25")
                }
            }
            .store(in: &cancellables)

        fetchNearbyStops()
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

            struct StopDistance {
                let stop: BusStop
                let cityCode: Int
                let distance: Double
            }

            let stopsWithDistance = stops.compactMap { stop -> StopDistance? in
                guard let cityCode = stop.cityCode else { return nil }
                let stopLocation = CLLocation(latitude: stop.latitude, longitude: stop.longitude)
                let distance = userLocation.distance(from: stopLocation)
                return StopDistance(stop: stop, cityCode: cityCode, distance: distance)
            }
            .sorted { $0.distance < $1.distance }

            let limitedStops = Array(stopsWithDistance.prefix(5))

            let repository = busRepository

            let nearbyStops = await withTaskGroup(
                of: (Int, BusStopForSearch?).self,
                returning: [BusStopForSearch].self
            ) { group in
                for (index, entry) in limitedStops.enumerated() {
                    group.addTask {
                        do {
                            let routes = try await repository.fetchRoutesPassingThroughStop(
                                cityCode: String(entry.cityCode),
                                nodeId: entry.stop.nodeId
                            )

                            let routeNumbers = routes.map(\.routeNumber).sorted()
                            let formattedDistance = Self.formatDistance(entry.distance)

                            let result = BusStopForSearch(
                                nodenm: entry.stop.name,
                                nodeid: entry.stop.nodeId,
                                routes: routeNumbers,
                                distance: formattedDistance
                            )
                            return (index, result)
                        } catch {
                            return (index, nil)
                        }
                    }
                }

                var orderedResults = [BusStopForSearch?](repeating: nil, count: limitedStops.count)
                for await (index, value) in group {
                    orderedResults[index] = value
                }

                return orderedResults.compactMap { $0 }
            }

            viewState = .success(nearbyStops)
        } catch {
            viewState = .error(error)
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
