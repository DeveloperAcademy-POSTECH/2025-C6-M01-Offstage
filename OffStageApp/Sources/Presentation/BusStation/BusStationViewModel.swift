import BusAPI
import Foundation

@MainActor
final class BusStationViewModel: ObservableObject {
    enum ViewState {
        case idle
        case loading
        case success([RouteDetail])
        case error(Error)
    }

    struct RouteDetail: Identifiable, Hashable {
        struct Arrival: Identifiable, Hashable {
            let id = UUID()
            let secondsUntilArrival: Int?
            let remainingStops: Int?
            let vehicleType: String?

            var arrivalDescription: String {
                guard let seconds = secondsUntilArrival else { return "정보 없음" }
                return seconds < 60 ? "곧 도착" : "\(seconds / 60)분"
            }

            var remainingStopsDescription: String? {
                guard let remainingStops else { return nil }
                return "\(remainingStops)번째전"
            }

            var vehicleDescription: String? {
                guard let vehicleType, !vehicleType.isEmpty else { return nil }
                return vehicleType
            }
        }

        let routeId: String
        let routeNumber: String
        let routeType: String?
        let direction: String
        let arrivals: [Arrival]

        var id: String { routeId }
    }

    let input: BusStationViewInput
    @Published private(set) var viewState: ViewState = .idle

    private let arrivalsFetcher: @Sendable (String, String) async throws -> [BusArrival]
    private let busRepository: BusRepository

    init(input: BusStationViewInput, busRepository: BusRepository) {
        self.input = input
        self.busRepository = busRepository
        arrivalsFetcher = { cityCode, nodeId in
            try await busRepository.fetchStopArrivals(cityCode: cityCode, nodeId: nodeId)
        }
    }

    init(
        input: BusStationViewInput,
        arrivalsFetcher: @escaping @Sendable (String, String) async throws -> [BusArrival],
        busRepository: BusRepository
    ) {
        self.input = input
        self.arrivalsFetcher = arrivalsFetcher
        self.busRepository = busRepository
    }

    func load() {
        guard case .idle = viewState else { return }
        viewState = .loading
        Task { await fetchArrivals() }
    }

    func refresh() {
        viewState = .loading
        Task { await fetchArrivals() }
    }

    private func fetchArrivals() async {
        do {
            let arrivals = try await arrivalsFetcher(input.cityCode, input.nodeId)
            print("BusStationViewModel - Fetched arrivals: \(arrivals)")

            let groupedByRouteId = Dictionary(grouping: arrivals, by: \.routeId)

            let details = await withTaskGroup(of: RouteDetail?.self, returning: [RouteDetail].self) { group in
                for (routeId, arrivalsForRoute) in groupedByRouteId {
                    group.addTask {
                        guard let firstArrival = arrivalsForRoute.first else { return nil }

                        let routeInfo = try? await self.busRepository.fetchRouteInfo(
                            cityCode: self.input.cityCode,
                            routeId: routeId
                        )

                        let mappedArrivals = arrivalsForRoute
                            .sorted {
                                ($0.estimatedArrivalTime ?? Int.max) < ($1.estimatedArrivalTime ?? Int.max)
                            }
                            .map { arrival in
                                RouteDetail.Arrival(
                                    secondsUntilArrival: arrival.estimatedArrivalTime,
                                    remainingStops: arrival.remainingStopCount,
                                    vehicleType: arrival.vehicleType
                                )
                            }

                        return RouteDetail(
                            routeId: routeId,
                            routeNumber: firstArrival.routeNumber,
                            routeType: firstArrival.routeType,
                            direction: routeInfo?.endStopName ?? "",
                            arrivals: mappedArrivals
                        )
                    }
                }

                var results = [RouteDetail]()
                for await result in group {
                    if let result {
                        results.append(result)
                    }
                }
                return results.sorted(by: { $0.routeNumber < $1.routeNumber })
            }

            print("DETAIL \n\n\n\n\n\(details)\n\n\n\n\n\n")

            viewState = .success(details)
        } catch {
            viewState = .error(error)
        }
    }
}

extension BusStationViewModel.RouteDetail {
    static let sample: Self = .init(
        routeId: "DJB30300004",
        routeNumber: "111",
        routeType: "간선버스",
        direction: "시청 방면",
        arrivals: [
            .init(secondsUntilArrival: 480, remainingStops: 2, vehicleType: "저상"),
            .init(secondsUntilArrival: 1320, remainingStops: 12, vehicleType: nil),
        ]
    )
}

#if DEBUG
    extension BusStationViewModel {
        func applyPreviewState(_ state: ViewState) {
            viewState = state
        }
    }
#endif
