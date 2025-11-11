import BusAPI
import SwiftUI

enum LegacyAppRoute: LegacyRoutable {
    case home
    case search
    case busVision(routeToDetect: [String])
    case busStation(input: BusStationViewInput)
    case homeEdit
    case onboarding
    case sttTest
    case quickCamera

    @MainActor
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .home:
            LegacyHomeView()

        case .search:
            // Use shared LocationManager so DebugView can toggle mock mode on the same instance
            let locationProvider: LocationProviding = LocationManager.shared
            let viewModel = LegacySearchViewModel(busRepository: MainBusRepository(), locationManager: locationProvider)
            LegacySearchView(viewModel: viewModel)

        case let .busStation(input):
            LegacyBusStationView(input: input)

        case let .busVision(routeToDetect):
            LegacyBusVisionView(routeNumbers: routeToDetect)

        case .homeEdit:
            LegacyHomeEditView()

        case .onboarding:
            LegacyOnboardingView()

        case .sttTest:
            STTandTTSTestView()

        case .quickCamera:
            QuickCameraView()
        }
    }
}
