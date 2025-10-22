import BusAPI
import SwiftUI

enum AppRoute: Routable {
    case home
    case search
    case busstation(busStopInfo: BusStopInfo)
    case busvision(routeToDetect: [String])
    case homeedit
    case onboarding
    case test(busStopInfo: BusStopInfo)

    @MainActor
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .home:
            HomeView()

        case .search:
            let viewModel = SearchViewModel(busRepository: DefaultBusRepository(), locationManager: LocationManager())
            SearchView(viewModel: viewModel)

        case .busstation:
            BusStationView()

        case let .busvision(routeToDetect):
            BusVisionView(routeNumbers: routeToDetect)

        case .homeedit:
            HomeEditView()

        case .onboarding:
            OnboardingView()

        case let .test(busStopInfo):
            TestView(busStopInfo: busStopInfo)
        }
    }
}
