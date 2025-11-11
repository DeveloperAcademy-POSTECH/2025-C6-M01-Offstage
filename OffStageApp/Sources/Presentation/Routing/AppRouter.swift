import BusAPI
import SwiftUI

enum AppRoute: Routable {
    case home
    case busVision(routeToDetect: [String])
    case sttTest
    case quickCamera

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
        }
    }
}
