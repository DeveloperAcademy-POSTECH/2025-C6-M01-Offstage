import BusAPI
import SwiftUI

// TODO: tts기반으로, busRoutes 목록 중 유사값 추측하는 모델 필요
struct SheetView: View {
    @AccessibilityFocusState private var isListeningFocused: Bool
    @AccessibilityFocusState private var isConfirmationFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var step: Int = 0
    @StateObject private var viewModel: SheetViewModel
    let nearestBusStopFromHome: BusStop?
    let busRoutes: [BusRoute] // New property
    let onRouteSelected: (BusRoute) -> Void

    init(
        nearestBusStop: BusStop?,
        busRoutes: [BusRoute], // New parameter
        onRouteSelected: @escaping (BusRoute) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: SheetViewModel(busRoutes: busRoutes))
        nearestBusStopFromHome = nearestBusStop
        self.busRoutes = busRoutes // Initialize
        self.onRouteSelected = onRouteSelected
    }

    var body: some View {
        ZStack {
            VStack {
                // Dismiss Button
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray.opacity(0.8))
                    }
                    .accessibilityLabel(L10n.Common.Ui.buttonCancel)
                }
                .padding()
                .padding(.bottom, 20)

                Spacer()

                // Content based on SheetState
                switch viewModel.currentSheetState {
                case .listening:
                    listeningContent()
                case let .confirmation(recognizedBusNumber):
                    confirmationContent(recognizedBusNumber: recognizedBusNumber)
                case let .busRouteList(routes):
                    busRouteListContent(routes: routes)
                }

                Spacer()
            }
        }
        .onAppear {
            viewModel.currentBusStop = nearestBusStopFromHome // Set initially
            viewModel.startListeningProcess()

            step = 0
            for i in 1 ... 3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.35) {
                    step = i
                }
            }
        }
        .onChange(of: nearestBusStopFromHome) { newBusStop in
            viewModel.currentBusStop = newBusStop // Update if HomeView's nearestBusStop changes
        }
        .onDisappear {
            viewModel.stopSpeaking()
        }
    }

    // MARK: - Listening Content

    @ViewBuilder
    private func listeningContent() -> some View {
        VStack {
            Text(L10n.Home.Stt.listening)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 30)
                .accessibilityFocused($isListeningFocused)
                .onAppear {
                    isListeningFocused = true
                }

            ZStack {
                // Concentric circles
                ForEach(1 ... 3, id: \.self) { i in
                    Circle()
                        .stroke(Color(.primarynormal).opacity([0.6, 0.4, 0.2][i - 1]), lineWidth: 6)
                        .frame(width: 110 + 48 * CGFloat(i))
                        .opacity(step >= i ? 1 : 0)
                        .animation(.easeOut(duration: 0.35), value: step)
                }

                // Central icon
                ZStack {
                    Circle()
                        .fill(.clear)
                        .frame(width: 90, height: 90)
                        .overlay(
                            Circle()
                                .stroke(Color(.primarynormal), lineWidth: 6)
                                .scaleEffect(1.2)
                        )

                    HStack(spacing: 5) {
                        Capsule().fill(.white).frame(width: 4, height: 10)
                        Capsule().fill(.white).frame(width: 4, height: 30)
                        Capsule().fill(.white).frame(width: 4, height: 50)
                        Capsule().fill(.white).frame(width: 4, height: 20)
                        Capsule().fill(.white).frame(width: 4, height: 40)
                        Capsule().fill(.white).frame(width: 4, height: 25)
                    }
                }
            }
            .task {
                // 순차로 나타났다 리셋(무한 반복)
                while true {
                    for i in 0 ... 3 {
                        step = i
                        try? await Task.sleep(for: .milliseconds(250)) // 간격 조절
                    }
                    try? await Task.sleep(for: .milliseconds(600)) // 다 켜진 상태 유지
                    step = 0 // 다시 중앙만
                    try? await Task.sleep(for: .milliseconds(300))
                }
            }

            Spacer() // Add another spacer to balance the VStack
        }
    }

    // MARK: - Confirmation Content

    @ViewBuilder
    private func confirmationContent(recognizedBusNumber: String) -> some View {
        VStack {
            (Text(L10n.BusVision.Detection.confirmBusNumberPrefix) +
                Text(recognizedBusNumber)
                .foregroundColor(Color(.primarynormal))
                .fontWeight(.bold) +
                Text(L10n.BusVision.Detection.confirmBusNumber)
            )
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.bottom, 40)
            .accessibilityFocused($isConfirmationFocused)
            .onAppear {
                isConfirmationFocused = true
            }

            VStack(spacing: 20) {
                Button(action: {
                    if let matchingRoute = busRoutes
                        .first(where: { $0.routeNumber.removeParenthesesContent() == recognizedBusNumber })
                    {
                        onRouteSelected(matchingRoute)
                        print("Confirmed and returned matching route: \(matchingRoute.routeNumber)")
                    } else {
                        // TODO: 일치하는 버스 노선이 없을 때 처리 필요
                        print("No matching bus route found for recognized number: \(recognizedBusNumber)")
                        dismiss()
                    }
                }) {
                    Text(L10n.Common.Confirmation.yes)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.yellow, lineWidth: 2)
                                .fill(Color.black.opacity(0.5))
                        )
                        .foregroundColor(.white)
                }

                Button(action: {
                    viewModel.startListeningProcess()
                }) {
                    Text(L10n.BusVision.Detection.retry)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.cyan, lineWidth: 2)
                                .fill(Color.black.opacity(0.5))
                        )
                        .foregroundColor(.white)
                }

                Button(action: {
                    viewModel.showBusRouteList(routes: busRoutes)
                }) {
                    Text(L10n.BusVision.Detection.selectFromList)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.green, lineWidth: 2)
                                .fill(Color.black.opacity(0.5))
                        )
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            Spacer() // Add another spacer to balance the VStack
        }
    }

    // MARK: - Bus Route List Content

    @ViewBuilder
    private func busRouteListContent(routes: [BusRoute]) -> some View {
        BusRouteListView(busRoutes: routes, onRouteSelected: onRouteSelected) // Pass the closure
    }
}
