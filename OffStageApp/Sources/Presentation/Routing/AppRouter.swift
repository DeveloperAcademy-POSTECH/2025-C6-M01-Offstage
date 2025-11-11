import BusAPI
import SwiftUI

enum AppRoute: Routable {
    case home
    case busVision(routeToDetect: [String])
    case sttTest
    case quickCamera
    case busArrival(busStop: BusStop, busRoute: BusRoute) // New route

    @MainActor
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .home:
            HomeView()

        case let .busVision(routeToDetect):
            BusVisionView(routeNumbers: routeToDetect)

        case .sttTest:
            STTandTTSTestView()

        case .quickCamera:
            QuickCameraView()

        case let .busArrival(busStop, busRoute): // Handle the new route
            BusArrivalView(busStop: busStop, busRoute: busRoute)
        }
    }
}
