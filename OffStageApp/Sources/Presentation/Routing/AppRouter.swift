import BusAPI
import SwiftUI

enum AppRoute: Routable {
    case home
    case permissionGuide
    case busRouteSearch(busStop: BusStop, recognizedText: String)
    case busVision(busStop: BusStop, busRoute: BusRoute)
    case sttTest
    case quickCamera
    case busArrival(busStop: BusStop, busRoute: BusRoute) // New route

    @MainActor
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .home:
            HomeView()

        case .permissionGuide:
            PermissionGuideView()

        case let .busRouteSearch(busStop, recognizedText):
            BusRouteSearchView(busStop: busStop, recognizedText: recognizedText)

        case let .busVision(busStop, busRoute):
            BusVisionView(busStop: busStop, busRoute: busRoute)

        case .sttTest:
            STTandTTSTestView()

        case .quickCamera:
            QuickCameraView()

        case let .busArrival(busStop, busRoute): // Handle the new route
            BusArrivalView(busStop: busStop, busRoute: busRoute)
        }
    }
}
