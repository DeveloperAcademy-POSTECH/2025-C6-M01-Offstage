import BusAPI
import SwiftUI

enum AppRoute: Routable {
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
            let viewModel = SearchViewModel(busRepository: MainBusRepository(), locationManager: locationProvider)
            SearchView(viewModel: viewModel)

        case let .busStation(input):
            BusStationView(input: input)

        case let .busVision(routeToDetect):
            LegacyBusVisionView(routeNumbers: routeToDetect)

        case .homeEdit:
            HomeEditView()

        case .onboarding:
            LegacyOnboardingView()

        case .sttTest:
            STTandTTSTestView()

        case .quickCamera:
            QuickCameraView()
        }
    }
}
