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
                VStack(alignment: .leading) {
                    Text("주변 정류장")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 16)

                    switch viewModel.viewState {
                    case .idle, .loading:
                        ActivityIndicator(isAnimating: .constant(true), style: .large)
                    case let .success(busStops):
                        VStack(spacing: 0) {
                            ForEach(busStops) { busStop in
                                Button(action: {
                                    // TODO: Fix navigation
                                    // router.push(.busstation(busStopInfo: busStopInfo))
                                }) {
                                    SearchResultsView(busStop: busStop)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            Divider()
                                .overlay(Color.gray.opacity(0.2))
                        }
                    case let .error(error):
                        Text("Error: \(error.localizedDescription)")
                    }
                }
                .padding(.horizontal, 16)
                .navigationBarItems(leading:
                    Button(action: {
                        router.popToRoot()
                    }, label: {
                        Image(systemName: "chevron.left")
                    })
                )
                .toolbar {
                    ToolbarItem(placement: .principal) { // 툴바 항목 배치
                        TextField("검색...", text: $viewModel.searchTerm)
                            .textFieldStyle(RoundedBorderTextFieldStyle()) // 텍스트 필드 스타일
                            .padding(.vertical, 4) // 좌우 여백 추가
                    }
                }
            }
        }
    }
}

#Preview {
    let viewModel = SearchViewModel(busRepository: DefaultBusRepository(), locationManager: LocationManager())
    viewModel.viewState = .success(BusStopForSearch.sampleBusStop)
    return SearchView(viewModel: viewModel)
        .environmentObject(Router<AppRoute>(root: .search))
}
