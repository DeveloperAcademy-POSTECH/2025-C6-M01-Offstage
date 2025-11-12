import BusAPI
import SwiftUI

// TODO: tts기반으로, busRoutes 목록 중 유사값 추측하는 모델 필요
struct SheetView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SheetViewModel()
    let nearestBusStopFromHome: BusStop?
    let busRoutes: [BusRoute] // New property
    let onRouteSelected: (BusRoute) -> Void

    init(
        nearestBusStop: BusStop?,
        busRoutes: [BusRoute], // New parameter
        onRouteSelected: @escaping (BusRoute) -> Void
    ) {
        _viewModel = StateObject(wrappedValue: SheetViewModel())
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
        }
        .onChange(of: nearestBusStopFromHome) { newBusStop in
            viewModel.currentBusStop = newBusStop // Update if HomeView's nearestBusStop changes
        }
        .onDisappear {
            viewModel.stopSpeaking()
            viewModel.stopListeningAnimation()
        }
    }

    // MARK: - Listening Content

    @ViewBuilder
    private func listeningContent() -> some View {
        VStack {
            Text("번호를 듣는중이에요.")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 30)

            ZStack {
                // Concentric circles
                ForEach(0 ..< 4) { i in
                    Circle()
                        .stroke(Color(.primarynormal).opacity(1 - Double(i) * 0.2), lineWidth: 2)
                        .frame(width: 120 + CGFloat(i * 50))
                        .scaleEffect(viewModel.isAnimating ? 1 : 0.9)
                        .animation(
                            .easeInOut(duration: 1).repeatForever().delay(Double(i) * 0.2),
                            value: viewModel.isAnimating
                        )
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
            Spacer() // Add another spacer to balance the VStack
        }
    }

    // MARK: - Confirmation Content

    @ViewBuilder
    private func confirmationContent(recognizedBusNumber: String) -> some View {
        VStack {
            (Text("타려는 버스 번호가\n") +
                Text(recognizedBusNumber)
                .foregroundColor(Color(.primarynormal))
                .fontWeight(.bold) +
                Text("번이 맞나요?")
            )
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.bottom, 40)

            VStack(spacing: 20) {
                Button(action: {
                    if let matchingRoute = busRoutes
                        .first(where: { $0.routeNumber.removeParenthesesContent() == recognizedBusNumber })
                    {
                        onRouteSelected(matchingRoute)
                        print("Confirmed and returned matching route: \(matchingRoute.routeNumber)")
                    } else {
                        print("No matching bus route found for recognized number: \(recognizedBusNumber)")
                        // Optionally, you could keep the sheet open or show an alert here.
                    }
                    dismiss()
                }) {
                    Text("네, 맞아요.")
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
                    Text("아니요, 다시 인식할게요")
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
                    Text("아니요, 목록에서 고를게요")
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
