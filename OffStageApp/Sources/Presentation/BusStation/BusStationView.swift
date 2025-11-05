import BusAPI
import SwiftData
import SwiftUI

struct BusStationView: View {
    @EnvironmentObject private var router: Router<AppRoute>
    @StateObject private var viewModel: BusStationViewModel
    @State private var countdown: Int = 10
    @State private var timer: Timer?
    @State private var rotationAngle: Angle = .zero
    @Query private var favorites: [Favorite]

    private var favoritedRoutesInThisStation: [Favorite] {
        favorites.filter { $0.nodeId == viewModel.input.nodeId }
    }

    private var isBusRecognitionDisabled: Bool {
        favoritedRoutesInThisStation.isEmpty
    }

    init(input: BusStationViewInput, busRepository: BusRepository = MainBusRepository()) {
        _viewModel = StateObject(wrappedValue: BusStationViewModel(input: input, busRepository: busRepository))
    }

    init(viewModel: BusStationViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 16) {
                header
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // 안내 문구
                        Text(L10n.BusStation.Ui.guidance)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .foregroundStyle(.gray)

                        // 버스 리스트
                        content
                    }
                }
                Button {
                    let destination = AppRoute.busVision(routeToDetect: favoritedRoutesInThisStation.map(\.routeNo))
                    router.push(destination)
                } label: {
                    HStack {
                        Image(systemName: "camera")
                            .accessibilityHidden(true)
                        Text(L10n.BusStation.Ui.buttonRecognizeBus)
                    }
                    .foregroundColor(isBusRecognitionDisabled ? .gray : .white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isBusRecognitionDisabled ? Color(.systemGray5) : Color.blue)
                    .cornerRadius(10)
                }
                .disabled(isBusRecognitionDisabled)
                .frame(maxWidth: .infinity)
            }
            .onAppear(perform: startTimer)
            .onDisappear(perform: stopTimer)
            .task { viewModel.load() }
            // TODO: arrivalDescription에 대한 동적 새로고침 로직을 구현해야 합니다.
            // 남은 시간이 길 때는 (예:25분 이상?) 5분마다 새로고침하고,
            // 시간이 줄어들수록 더 자주 새로고침해야 합니다.
            .navigationBarItems(
                trailing:
                Button(action: { router.popToRoot() }) {
                    Image(systemName: "house")
                }
                .accessibilityLabel(Text(L10n.Common.A11y.buttonHome))
            )

            RefreshButton(countdown: countdown, rotationAngle: $rotationAngle) {
                viewModel.refresh()
                resetTimer()
                withAnimation(.easeInOut(duration: 0.6)) {
                    rotationAngle += .degrees(360)
                }
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.input.nodeName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text(viewModel.input.nodeNumber ?? "-")
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color(.systemGray6))
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .idle, .loading:
            ActivityIndicator(isAnimating: .constant(true), style: .large)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 40)

        case let .success(routes):
            if routes.isEmpty {
                Group {
                    if viewModel.input.routes.isEmpty {
                        Text(L10n.BusStation.Ui.errorNoRoutes)
                    } else {
                        Text(L10n.BusStation.Ui.errorNoArrivalInfo)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.secondary)
                .padding(.vertical, 40)
            } else {
                BusStationListSubView(routes: routes, viewInput: viewModel.input)
                    .padding(.horizontal, 16)
            }

        case let .error(error):
            VStack(spacing: 12) {
                Text(L10n.BusStation.Ui.errorFailedToLoad)
                    .foregroundColor(.secondary)
                Text(error.localizedDescription)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Button(L10n.Common.Ui.buttonRetry) {
                    viewModel.refresh()
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 32)
        }
    }

    private func startTimer() {
        stopTimer() // Ensure no multiple timers are running
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if countdown > 0 {
                countdown -= 1
            } else {
                viewModel.refresh()
                countdown = 10
                withAnimation(.easeInOut(duration: 0.6)) {
                    rotationAngle += .degrees(360)
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func resetTimer() {
        countdown = 10
        startTimer()
    }
}
