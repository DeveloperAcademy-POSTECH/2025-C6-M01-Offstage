import BusAPI
import SwiftUI

// TODO: ; 30초마다 API 재호출

struct BusArrivalView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: Router<AppRoute> // Inject router
    @StateObject private var viewModel: BusArrivalViewModel

    init(busStop: BusStop, busRoute: BusRoute) {
        _viewModel = StateObject(wrappedValue: BusArrivalViewModel(busStop: busStop, busRoute: busRoute))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if let arrival = viewModel.busArrivalInfo {
                BusArrivalInfoView(
                    arrival: arrival,
                    busRoute: viewModel.busRoute,
                    currentEstimatedArrivalTime: viewModel.currentEstimatedArrivalTime
                )
            } else if let location = viewModel.busLocationInfo {
                BusLocationInfoView(location: location, busRoute: viewModel.busRoute)
            }

            Spacer()
            VStack(alignment: .center, spacing: 10) {
                // Callout/Emphasized
                Text("도착 예정 시간이 1분 미만일 때\n버스 인식을 시작할 수 있어요")
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 5)

                // Bus Vision Button
                Button(action: {
                    router.push(.busVision(routeToDetect: [viewModel.busRoute.routeNumber]))
                }) {
                    HStack {
                        Image(systemName: "camera")
                        Text("버스 인식하기")
                    }
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.white))
                    .padding(.vertical, 13)
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.primarynormal), lineWidth: 2)
                    )
                    .cornerRadius(10)
                }
                .disabled(!viewModel.isBusVisionButtonEnabled) // Disable based on ViewModel state
                .opacity(viewModel.isBusVisionButtonEnabled ? 1.0 : 0.5) // Visual feedback for disabled state
            }
        }.padding()
            .onAppear {
                viewModel.fetchArrivalInfo()
            }
            .onDisappear {
                viewModel.stopArrivalTimer() // Stop timer when view disappears
            }
    }
}

// Helper View for Bus Arrival Info
struct BusArrivalInfoView: View {
    let arrival: BusArrival
    let busRoute: BusRoute
    let currentEstimatedArrivalTime: Int? // New property

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "bus.fill")
                    .foregroundColor(.white)
                Text(busRoute.routeNumber) // Use busRoute.routeNumber
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .foregroundColor(.white)
            }
            .background(Capsule().fill(Color.gray.opacity(0.5)))
            .padding(.top, 5)
            .padding(.bottom, 8)

            Text(formatArrivalTime(currentEstimatedArrivalTime)) // Use mutable time
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("도착 예정")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))

            if let remainingStops = arrival.remainingStopCount {
                (Text("\(remainingStops)")
                    .foregroundColor(.white)
                    .fontWeight(.bold) +
                    Text("번째전 정류장에 있습니다.")
                )
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.8)
                )
            }
        }
    }

    private func formatArrivalTime(_ seconds: Int?) -> String {
        guard let seconds else { return "정보 없음" }
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return "\(minutes)분 \(remainingSeconds)초 후"
    }
}

// Helper View for Bus Location Info (Fallback)
struct BusLocationInfoView: View {
    let location: BusLocation
    let busRoute: BusRoute

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "bus.fill")
                    .foregroundColor(.white)
                Text(busRoute.routeNumber)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.gray.opacity(0.5)))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 10)

            Text("도착 예정 정보 없음")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("현재 운행중인 버스 위치:")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))

            Text("\(location.nodeName ?? "알 수 없는 위치") 인근")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}
