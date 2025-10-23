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

        let routeNumber: String
        let routeType: String?
        let arrivals: [Arrival]

        var id: String { routeNumber }
    }

    let input: BusStationViewInput
    @Published private(set) var viewState: ViewState = .idle

    private let arrivalsFetcher: @Sendable (String, String) async throws -> [BusArrival]

    init(input: BusStationViewInput, busRepository: BusRepository) {
        self.input = input
        arrivalsFetcher = { cityCode, nodeId in
            try await busRepository.fetchStopArrivals(cityCode: cityCode, nodeId: nodeId)
        }
    }

    init(
        input: BusStationViewInput,
        arrivalsFetcher: @escaping @Sendable (String, String) async throws -> [BusArrival]
    ) {
        self.input = input
        self.arrivalsFetcher = arrivalsFetcher
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

            let grouped = Dictionary(grouping: arrivals, by: \.routeNumber)

            let details = grouped.keys.sorted().map { routeNumber -> RouteDetail in
                let arrivalsForRoute = (grouped[routeNumber] ?? [])
                    .sorted {
                        ($0.estimatedArrivalTime ?? Int.max) < ($1.estimatedArrivalTime ?? Int.max)
                    }

                let mappedArrivals = arrivalsForRoute.map { arrival in
                    RouteDetail.Arrival(
                        secondsUntilArrival: arrival.estimatedArrivalTime,
                        remainingStops: arrival.remainingStopCount,
                        vehicleType: arrival.vehicleType
                    )
                }

                return RouteDetail(
                    routeNumber: routeNumber,
                    routeType: arrivalsForRoute.first?.routeType,
                    arrivals: mappedArrivals
                )
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
        routeNumber: "111",
        routeType: "간선버스",
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
