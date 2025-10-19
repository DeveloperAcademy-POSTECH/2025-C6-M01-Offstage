// import BusAPI
// import Combine
// import Foundation
// import Moya
//
// @MainActor
// final class SearchViewModel: ObservableObject {
//    enum ViewState {
//        case idle
//        case loading
//        case success([BusStop])
//        case error(Error)
//    }
//
//    @Published var viewState: ViewState = .idle
//    @Published var searchTerm: String = ""
//
//    private var cancellables = Set<AnyCancellable>()
//    private let busAPI = MoyaProvider<BusAPI>()
//
//    init(location: LocationCoordinate?) {
//        $searchTerm
//            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
//            .removeDuplicates()
//            .sink { [weak self] term in
//                guard let self else { return }
//                if term.isEmpty {
//                    if let location {
//                        fetchNearbyStops(latitude: location.latitude, longitude: location.longitude)
//                    } else {
//                        viewState = .idle
//                    }
//                } else {
//                    // TODO: Need to get cityCode from somewhere
//                    searchStops(query: term, cityCode: "25")
//                }
//            }
//            .store(in: &cancellables)
//
//        if let location, searchTerm.isEmpty {
//            fetchNearbyStops(latitude: location.latitude, longitude: location.longitude)
//        }
//    }
//
//    func fetchNearbyStops(latitude: Double, longitude: Double) {
//        viewState = .loading
//        busAPI.request(.getStopsByGps(gpsLati: latitude, gpsLong: longitude)) { [weak self] result in
//            guard let self else { return }
//            switch result {
//            case let .success(response):
//                do {
//                    let apiResponse = try response.map(ApiResponse<ItemBody<BusStop>>.self)
//                    if let items = apiResponse.response.body?.items.item {
//                        viewState = .success(items)
//                    } else {
//                        viewState = .success([])
//                    }
//                } catch {
//                    viewState = .error(error)
//                }
//            case let .failure(error):
//                viewState = .error(error)
//            }
//        }
//    }
//
//    func searchStops(query: String, cityCode: String) {
//        viewState = .loading
//        busAPI.request(.searchStop(cityCode: cityCode, stopName: query)) { [weak self] result in
//            guard let self else { return }
//            switch result {
//            case let .success(response):
//                do {
//                    let apiResponse = try response.map(ApiResponse<ItemBody<BusStop>>.self)
//                    if let items = apiResponse.response.body?.items.item {
//                        viewState = .success(items)
//                    } else {
//                        viewState = .success([])
//                    }
//                } catch {
//                    viewState = .error(error)
//                }
//            case let .failure(error):
//                viewState = .error(error)
//            }
//        }
//    }
// }
