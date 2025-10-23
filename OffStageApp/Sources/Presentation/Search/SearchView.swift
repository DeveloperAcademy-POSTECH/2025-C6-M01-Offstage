import BusAPI
import SwiftUI

struct SearchView: View {
    @EnvironmentObject var router: Router<AppRoute>
    @StateObject private var viewModel: SearchViewModel

    init(viewModel: SearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if viewModel.searchTerm.isEmpty {
                        Text("주변 정류장")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 16)
                    }

                    switch viewModel.viewState {
                    case .idle, .loading:
                        if viewModel.searchTerm.isEmpty, !viewModel.nearbyStopsCache.isEmpty {
                            stopList(viewModel.nearbyStopsCache)
                        } else {
                            ActivityIndicator(isAnimating: .constant(true), style: .large)
                        }
                    case let .success(busStops):
                        let dataSource = viewModel.searchTerm.isEmpty ? viewModel.nearbyStopsCache : busStops
                        if dataSource.isEmpty {
                            Text("표시할 정류장이 없습니다.")
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                        } else {
                            stopList(dataSource)
                        }
                    case let .error(error):
                        Text("Error: \(error.localizedDescription)")
                    }
                }
                .padding(.horizontal, 16)
                .toolbar {
                    ToolbarItem(placement: .principal) { // 툴바 항목 배치
                        TextField("검색...", text: $viewModel.searchTerm)
                            .textFieldStyle(RoundedBorderTextFieldStyle()) // 텍스트 필드 스타일
                            .submitLabel(.search)
                            .onSubmit {
                                viewModel.submitSearch()
                            }
                            .padding(.vertical, 4) // 좌우 여백 추가
                    }
                }
            }
        }
    }
}

private extension SearchView {
    @ViewBuilder
    func stopList(_ stops: [BusStopForSearch]) -> some View {
        VStack(spacing: 0) {
            ForEach(stops) { busStop in
                SearchResultsView(busStop: busStop) {
                    guard let input = viewModel.destinationInput(for: busStop) else { return }
                    router.push(.busstation(input: input))
                }
            }
            Divider()
                .overlay(Color.gray.opacity(0.2))
        }
    }
}

#Preview {
    let viewModel = SearchViewModel(busRepository: DefaultBusRepository(), locationManager: LocationManager())
    viewModel.viewState = .success(BusStopForSearch.sampleBusStop)
    return SearchView(viewModel: viewModel)
        .environmentObject(Router<AppRoute>(root: .search))
}
