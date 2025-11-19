import AVFoundation
import BusAPI
import SwiftUI

struct BusArrivalView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var router: Router<AppRoute>
    @StateObject private var viewModel: BusArrivalViewModel

    init(busStop: BusStop, busRoute: BusRoute) {
        _viewModel = StateObject(wrappedValue: BusArrivalViewModel(busStop: busStop, busRoute: busRoute))
    }

    init(busStop: BusStop, routeWithArrival: BusRouteWithArrival) {
        _viewModel = StateObject(wrappedValue: BusArrivalViewModel(
            busStop: busStop,
            busRoute: routeWithArrival.route,
            initialArrival: routeWithArrival.arrival
        ))
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
            } else if let routeWithArrival = viewModel.routeWithArrival {
                BusArrivalInfoView(
                    routeWithArrival: routeWithArrival,
                    currentEstimatedArrivalTime: viewModel.currentEstimatedArrivalTime,
                    busUrgencyStatus: viewModel.busUrgencyStatus
                )
            } else if let location = viewModel.busLocationInfo {
                BusLocationInfoView(location: location, busRoute: viewModel.busRoute)
            }

            Spacer()
            VStack(alignment: .center, spacing: 10) {
                // Callout/Emphasized
                Text(L10n.Home.Sheet.busDetectionGuide)
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 5)

                // Bus Vision Button
                Button(action: {
                    router.push(.busVision(
                        busStop: viewModel.busStop,
                        busRoute: viewModel.busRoute
                    ))
                }) {
                    HStack {
                        Image(systemName: "camera")
                        Text(L10n.Home.Sheet.startBusDetection)
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
            .onChange(of: viewModel.routeWithArrival) { _, newRouteWithArrival in
                if let arrival = newRouteWithArrival?.arrival {
                    let announcement = generateAnnouncementLabel(
                        arrival: arrival,
                        busRoute: viewModel.busRoute,
                        currentEstimatedArrivalTime: viewModel.currentEstimatedArrivalTime,
                        busUrgencyStatus: viewModel.busUrgencyStatus
                    )
                    /// TODO:
                    /// - api 호출 주기 짧게 만든 후, 테스트 필요
                    /// - 짧은 시간에 공지가 연속 게시되면 이전 멘트를 중단하고 새 멘트를 읽어 "문장이 씹히는" 현상이 발생함
                    UIAccessibility.post(notification: .announcement, argument: announcement)
                }
            }
    }

    private func generateAnnouncementLabel(
        arrival: BusArrival,
        busRoute: BusRoute,
        currentEstimatedArrivalTime: Int?,
        busUrgencyStatus: BusUrgencyStatus
    ) -> String {
        BusArrivalFormatter.generateArrivalLabel(
            arrival: arrival,
            busRoute: busRoute,
            currentEstimatedArrivalTime: currentEstimatedArrivalTime,
            busUrgencyStatus: busUrgencyStatus
        )
    }
}

// 버스 도착 정보 헬퍼 뷰
struct BusArrivalInfoView: View {
    let routeWithArrival: BusRouteWithArrival
    let currentEstimatedArrivalTime: Int?
    let busUrgencyStatus: BusUrgencyStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "bus.fill")
                    .foregroundColor(.white)
                Text(routeWithArrival.route.routeNumber)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .accessibilityElement(children: .combine)
            .padding(8)
            .background(Color.gray.opacity(0.5))
            .cornerRadius(12)
            .padding(.top, 5)
            .padding(.bottom, 8)

            Text(BusArrivalFormatter.formatArrivalTime(currentEstimatedArrivalTime))
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(L10n.Bus.Arrival.imminent)
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))

            if let arrival = routeWithArrival.arrival {
                Text(BusArrivalFormatter.formatRemainingStops(arrival.remainingStopCount ?? 0))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(generateArrivalLabel()))
        .accessibilityAddTraits(.updatesFrequently)
    }

    private func generateArrivalLabel() -> String {
        guard let arrival = routeWithArrival.arrival else {
            return "\(routeWithArrival.route.routeNumber)번 버스 도착 정보 없음"
        }
        return BusArrivalFormatter.generateArrivalLabel(
            arrival: arrival,
            busRoute: routeWithArrival.route,
            currentEstimatedArrivalTime: currentEstimatedArrivalTime,
            busUrgencyStatus: busUrgencyStatus
        )
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

            Text(L10n.Bus.Arrival.noInformation)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(L10n.Bus.Arrival.currentBusLocation)
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))

            let locationName = location.nodeName ?? String(localized: "common.ui.unknownLocation")
            Text(String(
                format: String(localized: "home.map.near"),
                locationName
            ))
            .font(.title3)
            .foregroundColor(.white.opacity(0.8))
        }
    }
}
