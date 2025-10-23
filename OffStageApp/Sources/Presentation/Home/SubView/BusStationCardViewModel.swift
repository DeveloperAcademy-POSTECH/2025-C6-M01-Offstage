import BusAPI
import Foundation

@MainActor
final class BusStationCardViewModel: ObservableObject {
    @Published private(set) var busArrivals: [BusArrival] = []
    private let busRepository: BusRepository
    private let nodeId: String
    private let cityCode: String

    init(busRepository: BusRepository, nodeId: String, cityCode: String) {
        self.busRepository = busRepository
        self.nodeId = nodeId
        self.cityCode = cityCode
    }

    func fetchArrivals() async {
        do {
            let arrivals = try await busRepository.fetchStopArrivals(cityCode: cityCode, nodeId: nodeId)
            print("BusStationCardViewModel - Fetched arrivals: \(arrivals)")
            busArrivals = arrivals
        } catch {
            print("Error fetching arrivals: \(error)")
            // Handle error appropriately, e.g., set an error state
        }
    }
}
