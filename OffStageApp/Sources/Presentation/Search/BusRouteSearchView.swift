import BusAPI
import SwiftUI

enum LoadingState {
    case loading
    case loaded([BusRouteWithArrival], filterState: FilterState)
    case empty
    case error(String)
}

enum FilterState: Equatable {
    case noFilter
    case filtered(hasResults: Bool)
}

struct BusRouteSearchView: View {
    @StateObject private var viewModel: BusRouteSearchViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: Router<AppRoute>
    @AccessibilityFocusState private var isTitleFocused: Bool
    @State private var isSheetPresented = false

    private var currentState: LoadingState {
        if viewModel.isLoading {
            return .loading
        } else if let errorMessage = viewModel.errorMessage {
            return .error(errorMessage)
        } else if viewModel.allBusRoutesLoaded {
            let hasFilterResults = viewModel.isFiltered && !viewModel.busRoutes.isEmpty
            let filterState: FilterState = hasFilterResults ? .filtered(hasResults: true) : .noFilter
            let displayRoutes = hasFilterResults ? viewModel.busRoutes : viewModel.allBusRoutes
            return .loaded(displayRoutes, filterState: filterState)
        } else {
            return .empty
        }
    }

    init(busStop: BusStop, recognizedText: String) {
        _viewModel = StateObject(wrappedValue: BusRouteSearchViewModel(
            busStop: busStop,
            recognizedText: recognizedText
        ))
    }

    var body: some View {
        ZStack {
            Color(Color(.black800))
                .ignoresSafeArea()

            VStack(spacing: 0) {
                searchBar
                    .background(Color(.backgroundstrong))
                switch currentState {
                case .loading:
                    Spacer()
                    loadingContent()
                    Spacer()
                case let .loaded(routes, filterState):
                    busRouteListContent(routes: routes, filterState: filterState)
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
        }
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
                    viewModel.recognizedText = recognizedText
                    router.push(.busRouteSearch(busStop: viewModel.busStop, recognizedText: recognizedText))
                }
            )
        }
    }

    private var searchBar: some View {
        BusSearchBar(
            text: $viewModel.recognizedText,
            onSubmit: {
                viewModel.performSearch()
            },
            onMicTap: {
                isSheetPresented = true
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 99)
                .stroke(Color(.black500), lineWidth: 2)
        )
        .padding(.horizontal)
        .padding(.top, 20)
        .padding(.bottom, 18)
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
    private func busRouteListContent(routes: [BusRouteWithArrival], filterState: FilterState) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                titleText(for: filterState)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityFocused($isTitleFocused)
                    .onAppear {
                        isTitleFocused = true
                    }
                Spacer()
            }
            .background(Color(.backgroundstrong))

            Divider()
                .background(Color(.black500))

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(routes, id: \.id) { routeWithArrival in
                        busRouteRow(routeWithArrival: routeWithArrival)
                        Divider()
                            .background(Color(.black500))
                    }
                    .background(Color(.backgroundstrong))

                    if case .noFilter = filterState {
                        searchPromptFooter
                    }
                }
            }
        }
    }

    private var searchPromptFooter: some View {
        VStack(spacing: 16) {
            Text("탑승할 버스를 찾기 어렵다면\n직접 번호를 입력해서 버스 인식을 시작해 보세요.")
                .font(.body)
                .foregroundColor(Color(.gray100))
                .multilineTextAlignment(.center)
                .padding(.top, 40)

            Button(action: {
                router.push(.quickCamera
                )
            }) {
                Text("버스 바로 인식")
                    .font(.body)
                    .fontWeight(.semibold)
                    .padding(.vertical, 13)
                    .padding(.horizontal, 20)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 99)
                            .stroke(Color(.gray100), lineWidth: 3)
                    )
            }
            .padding(.horizontal, 40)
        }
        .padding(.bottom, 40)
    }

    private func titleText(for filterState: FilterState) -> some View {
        let text: String = switch filterState {
        case .noFilter:
            "경유하는 다른 버스를 확인해보세요."
        case let .filtered(hasResults):
            hasResults ? "버스 도착 정보" : "경유하는 다른 버스를 확인해보세요."
        }

        return VStack(alignment: .leading, spacing: 0) {
            if filterState == .noFilter {
                Text("\(viewModel.busStop.name) 정류장에는\n일치하는 버스가 없습니다.")
                    .font(.body)
                    .foregroundColor(Color(.gray100))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color(.backgroundheavy))
            }

            // "버스 도착 정보"일 때만 Divider 추가
            if case .filtered(hasResults: true) = filterState {
                Rectangle()
                    .fill(Color(.backgroundheavy))
                    .frame(maxWidth: .infinity)
                    .frame(height: 5)
            }

            Text(text)
                .font(.body)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
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
