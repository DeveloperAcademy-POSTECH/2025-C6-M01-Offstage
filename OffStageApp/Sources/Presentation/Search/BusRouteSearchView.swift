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
        .navigationTitle("번호 입력 확인")
        .navigationBarTitleDisplayMode(.inline)
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            viewModel.startAutoRefresh()
        }
        .onDisappear {
            viewModel.stopAutoRefresh()
        }
        .onChange(of: viewModel.allBusRoutes) { oldValue, newValue in
            if !oldValue.isEmpty, !newValue.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    UIAccessibility.post(
                        notification: .announcement,
                        argument: String(localized: "busRouteSearch.a11y.announcement.dataRefreshed")
                    )
                }
            }
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

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
                .lineLimit(nil)
        }
    }

    @ViewBuilder
    private func busRouteListContent(routes: [BusRouteWithArrival], filterState: FilterState) -> some View {
        VStack {
            Rectangle()
                .fill(Color(.backgroundheavy))
                .frame(maxWidth: .infinity)
                .frame(height: 5)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    titleText(for: filterState)
                        .background(Color(.backgroundstrong))
                        .accessibilityAddTraits(.isHeader)
                    Divider()
                        .background(Color(.black500))

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
            .simultaneousGesture(
                TapGesture().onEnded { _ in
                    hideKeyboard()
                }
            )
        }
    }

    private var searchPromptFooter: some View {
        VStack(spacing: 16) {
            Text("탑승할 버스를 찾기 어렵다면\n직접 번호를 입력해서 버스 인식을 시작해 보세요.")
                .font(.body)
                .foregroundColor(Color(.gray100))
                .multilineTextAlignment(.center)
                .padding(.top, 40)
                .lineLimit(nil)

            Button(action: {
                router.push(.quickCamera(routeNo: viewModel.recognizedText))
            }) {
                Text("버스 바로 인식")
                    .lineLimit(nil)
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
            .accessibilityLabel(String(localized: "busRouteSearch.a11y.button.quickRecognition.label"))
            .accessibilityHint(String(localized: "busRouteSearch.a11y.button.quickRecognition.hint"))
        }
        .padding(.bottom, 40)
    }

    @ViewBuilder
    private func titleText(for filterState: FilterState) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            switch filterState {
            case .noFilter:
                noFilterText
                filteredWithoutResultsText
            case let .filtered(hasResults):
                if hasResults {
                    filteredWithResultsText
                } else {
                    filteredWithoutResultsText
                }
            }
        }
    }

    private var noFilterText: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(viewModel.busStop.name) 정류장에는\n일치하는 버스가 없습니다.")
                .font(.body)
                .foregroundColor(Color(.gray100))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(red: 13 / 255, green: 14 / 255, blue: 17 / 255))
        }
    }

    private var filteredWithResultsText: some View {
        Text("버스 도착 정보")
            .font(.body)
            .foregroundColor(.white)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var filteredWithoutResultsText: some View {
        Text("경유하는 다른 버스를 확인해보세요.")
            .font(.body)
            .foregroundColor(.white)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
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
                        .lineLimit(nil)

                    if let arrival = routeWithArrival.arrival {
                        Text(BusArrivalFormatter.formatSimpleArrivalInfo(
                            remainingStops: arrival.remainingStopCount,
                            arrivalTime: arrival.estimatedArrivalTime
                        ))
                        .font(.body)
                        .foregroundColor(Color(.primarynormal))
                        .lineLimit(nil)
                    } else {
                        Text("도착 예정 정보 없음")
                            .font(.body)
                            .foregroundColor(.gray)
                            .lineLimit(nil)
                    }
                }

                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityHint(String(localized: "busRouteSearch.a11y.row.hint"))
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
                .lineLimit(nil)
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
                .lineLimit(nil)
        }
    }
}
