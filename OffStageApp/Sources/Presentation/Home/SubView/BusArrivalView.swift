import BusAPI
import SwiftUI

struct BusArrivalView: View {
    @Environment(\.dismiss) private var dismiss
    // 라우터 주입
    @EnvironmentObject var router: Router<AppRoute>
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
                    currentEstimatedArrivalTime: viewModel.currentEstimatedArrivalTime,
                    busUrgencyStatus: viewModel.busUrgencyStatus
                )
            } else if let location = viewModel.busLocationInfo {
                BusLocationInfoView(location: location, busRoute: viewModel.busRoute)
            }

            Spacer()
            VStack(alignment: .center, spacing: 10) {
                // Callout/Emphasized
                Text("버스가 직전 정류장에서 출발하면\n버스 인식을 시작할 수 있어요.")
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
                // ViewModel 상태에 따라 비활성화
                .disabled(!viewModel.isBusVisionButtonEnabled)
                // 비활성화 상태에 대한 시각적 피드백
                .opacity(viewModel.isBusVisionButtonEnabled ? 1.0 : 0.5)
            }
        }.padding()
            .onAppear {
                viewModel.startMonitoring()
            }
            .onDisappear {
                // 뷰가 사라질 때 타이머와 새로고침을 중지합니다.
                viewModel.stopMonitoring()
            }
    }
}

// 버스 도착 정보 헬퍼 뷰
struct BusArrivalInfoView: View {
    let arrival: BusArrival
    let busRoute: BusRoute
    let currentEstimatedArrivalTime: Int?
    let busUrgencyStatus: BusUrgencyStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "bus.fill")
                    .foregroundColor(.white)
                // busRoute.routeNumber 사용
                Text(busRoute.routeNumber)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(8)
            .background(Color.gray.opacity(0.5))
            .cornerRadius(12)
            .padding(.top, 5)
            .padding(.bottom, 8)
            // Use mutable time
            Text(formatArrivalTime(currentEstimatedArrivalTime))
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("도착 예정")
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))

            Text(formatRemainingStops(arrival.remainingStopCount ?? 0))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.8))
        }
    }

    private func formatRemainingStops(_ remainingStops: Int) -> String {
        var result = ""
        if remainingStops > 1 {
            result = "\(remainingStops)번째전"
        } else {
            result = "전"
        }
        return result + " 정류장에서 출발했습니다."
    }

    private func formatArrivalTime(_ seconds: Int?) -> String {
        guard let seconds else { return "정보 없음" }
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        if minutes >= 1 {
            return "\(minutes)분 \(remainingSeconds)초 후"
        }

        return "잠시 후"
        // return "\(remainingSeconds)초 후"
    }
}

// 버스 위치 정보 Helper View (Fallback)
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
