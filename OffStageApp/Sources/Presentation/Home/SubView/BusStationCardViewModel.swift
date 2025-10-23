import BusAPI
import Foundation

@MainActor
final class BusStationCardViewModel: ObservableObject {
    @Published private(set) var busArrivals: [BusArrival] = []
    private let busRepository: BusRepository
    private let nodeId: String
    private let cityCode: String
    private let favorites: [Favorite]

    init(busRepository: BusRepository, nodeId: String, cityCode: String, favorites: [Favorite]) {
        self.busRepository = busRepository
        self.nodeId = nodeId
        self.cityCode = cityCode
        self.favorites = favorites
    }

    func fetchArrivals() async {
        do {
            busArrivals = try await withThrowingTaskGroup(
                of: [BusArrival].self,
                returning: [BusArrival].self
            ) { group in
                for favorite in favorites {
                    group.addTask {
                        try await self.busRepository.fetchRouteArrivals(
                            cityCode: self.cityCode,
                            nodeId: self.nodeId,
                            routeId: favorite.routeId
                        )
                    }
                }

                var result = [BusArrival]()
                for try await arrivals in group {
                    result.append(contentsOf: arrivals)
                }
                return result.sorted(by: { $0.routeNumber < $1.routeNumber })
            }
        } catch {
            print("Error fetching arrivals: \(error)")
            // Handle error appropriately, e.g., set an error state
        }
    }
}
