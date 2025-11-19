import BusAPI
import SwiftUI

enum LoadingState {
    case loading
    case loaded([BusRouteWithArrival])
    case empty
    case error(String)
}

struct BusRouteSearchView: View {
    @StateObject private var viewModel: BusRouteSearchViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: Router<AppRoute>
    @AccessibilityFocusState private var isTitleFocused: Bool
    @State private var isSheetPresented = false

    private var currentState: LoadingState {
        if viewModel.isLoading {
            .loading
        } else if let errorMessage = viewModel.errorMessage {
            .error(errorMessage)
        } else if !viewModel.busRoutes.isEmpty {
            .loaded(viewModel.busRoutes)
        } else {
            .empty
        }
    }

    init(busStop: BusStop, recognizedText: String) {
        _viewModel = StateObject(wrappedValue: BusRouteSearchViewModel(
            busStop: busStop,
            recognizedText: recognizedText
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            switch currentState {
            case .loading:
                Spacer()
                loadingContent()
                Spacer()
            case let .loaded(routes):
                busRouteListContent(routes: routes)
            case let .error(message):
                Spacer()
                errorContent(message: message)
                Spacer()
            case .empty:
                Spacer()
                emptyContent()
                Spacer()
            }
        }
        .background(Color.black)
        .onAppear {
            viewModel.startAutoRefresh()
        }
        .onDisappear {
            viewModel.stopAutoRefresh()
        }
        .sheet(isPresented: $isSheetPresented) {
            SheetView(
                onTextRecognized: { recognizedText in
                    print("STT 완료: \(recognizedText)")
                    isSheetPresented = false
                    viewModel.searchText = recognizedText
                    router.push(.busRouteSearch(busStop: viewModel.busStop, recognizedText: recognizedText))
                }
            )
        }
    }

    private var searchBar: some View {
        BusSearchBar(
            text: $viewModel.searchText,
            onSubmit: {
                if !viewModel.searchText.isEmpty {
                    router.push(.busRouteSearch(
                        busStop: viewModel.busStop,
                        recognizedText: viewModel.searchText
                    ))
                }
            },
            onMicTap: {
                isSheetPresented = true
            }
        )
        .padding(.horizontal)
        .padding(.bottom, 30)
    }

    @ViewBuilder
    private func loadingContent() -> some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(2)
            Text("API 호출중")
                .font(.title2)
                .foregroundColor(.white)
                .padding(.top, 20)
        }
    }

    @ViewBuilder
    private func busRouteListContent(routes: [BusRouteWithArrival]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("버스 도착 정보")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.bottom, 20)
                .accessibilityAddTraits(.isHeader)
                .accessibilityFocused($isTitleFocused)
                .onAppear {
                    isTitleFocused = true
                }

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(routes, id: \.id) { routeWithArrival in
                        busRouteRow(routeWithArrival: routeWithArrival)
                        Divider()
                            .background(Color.gray.opacity(0.3))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func busRouteRow(routeWithArrival: BusRouteWithArrival) -> some View {
        Button(action: {
            print("Selected bus route: \(routeWithArrival.route.routeNumber)")
            router.push(.busArrival(busStop: viewModel.busStop, busRoute: routeWithArrival.route))
        }) {
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: "bus.fill")
                    .font(.title2)
                    .foregroundColor(.white)

                VStack(alignment: .leading, spacing: 4) {
                    Text(routeWithArrival.route.routeNumber)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    if let arrival = routeWithArrival.arrival {
                        Text(BusArrivalFormatter.formatSimpleArrivalInfo(
                            remainingStops: arrival.remainingStopCount,
                            arrivalTime: arrival.estimatedArrivalTime
                        ))
                        .font(.body)
                        .foregroundColor(Color(.primarynormal))
                    } else {
                        Text("도착 예정 정보 없음")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                }

                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private func errorContent(message: String) -> some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text(message)
                .font(.title2)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
        }
    }

    @ViewBuilder
    private func emptyContent() -> some View {
        VStack {
            Image(systemName: "bus")
                .font(.largeTitle)
                .foregroundColor(.gray)
            Text("버스 노선을 찾을 수 없습니다")
                .font(.title2)
                .foregroundColor(.white)
                .padding()
        }
    }
}
