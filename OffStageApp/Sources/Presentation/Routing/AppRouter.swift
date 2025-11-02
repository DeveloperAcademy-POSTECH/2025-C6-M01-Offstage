import BusAPI
import SwiftUI

enum AppRoute: Routable {
    case home
    case search
    case busvision(routeToDetect: [String])
    case busstation(input: BusStationViewInput)
    case homeedit
    case onboarding
    case test(busStopInfo: BusStopInfo)
    case sttstest

    @MainActor
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .home:
            HomeView()

        case .search:
            let viewModel = SearchViewModel(busRepository: DefaultBusRepository(), locationManager: LocationManager())
            SearchView(viewModel: viewModel)

        case let .busstation(input):
            BusStationView(input: input)

        case let .busvision(routeToDetect):
            BusVisionView(routeNumbers: routeToDetect)

        case .homeedit:
            HomeEditView()

        case .onboarding:
            OnboardingView()

        case let .test(busStopInfo):
            TestView(busStopInfo: busStopInfo)

        case .sttstest:
            STTandTTSTestView()
        }
    }
}
