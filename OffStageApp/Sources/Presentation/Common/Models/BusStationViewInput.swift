import Foundation

/// Immutable data passed into `LegacyBusStationView`.
struct BusStationViewInput: Hashable {
    let cityCode: String
    let nodeId: String
    let nodeName: String
    let nodeNumber: String?
    let routes: [String]
}
