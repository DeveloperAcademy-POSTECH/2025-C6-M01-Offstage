import AVFoundation
import BusAPI
import SwiftUI

enum BusArrivalViewState {
    case loading
    case error(String)
    case arrival(BusRouteWithArrival, currentEstimatedTime: Int?)
    case location(BusLocation)
    case empty
}

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

    private var currentViewState: BusArrivalViewState {
        if viewModel.isLoading {
            .loading
        } else if let errorMessage = viewModel.errorMessage {
            .error(errorMessage)
        } else if let routeWithArrival = viewModel.routeWithArrival {
            .arrival(routeWithArrival, currentEstimatedTime: viewModel.currentEstimatedArrivalTime)
        } else if let location = viewModel.busLocationInfo {
            .location(location)
        } else {
            .empty
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                switch currentViewState {
                case .loading:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity, alignment: .center)
                case let .error(message):
                    Text(message)
                        .font(.title2)
                        .foregroundColor(.white)
                        .lineLimit(nil)
                        .frame(maxWidth: .infinity, alignment: .center)
                case let .arrival(routeWithArrival, currentEstimatedTime):
                    BusArrivalInfoView(
                        routeWithArrival: routeWithArrival,
                        currentEstimatedArrivalTime: currentEstimatedTime
                    )
                case let .location(location):
                    BusLocationInfoView(location: location, busRoute: viewModel.busRoute)
                case .empty:
                    Text("버스 정보를 찾을 수 없습니다")
                        .font(.title2)
                        .foregroundColor(.white)
                        .lineLimit(nil)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                Spacer()
                VStack(alignment: .center, spacing: 10) {
                    Text(L10n.Home.Sheet.busDetectionGuide)
                        .font(.callout)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 5)
                        .lineLimit(nil)

                    Button(action: {
                        router.push(.busVision(
                            busStop: viewModel.busStop,
                            busRoute: viewModel.busRoute
                        ))
                    }) {
                        HStack {
                            Image(systemName: "camera")
                            Text(L10n.Home.Sheet.startBusDetection)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.white))
                        .padding(.vertical, 13)
                        .padding(.horizontal, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 99)
                            .stroke(Color(.primarynormal), lineWidth: 2)
                    )
                    .cornerRadius(99)
                }
            }
        }
        .padding()
        .onAppear {
            viewModel.startMonitoring()
        }
        .onDisappear {
            // 뷰가 사라질 때 타이머와 새로고침을 중지합니다.
            viewModel.stopMonitoring()
        }
        .onChange(of: viewModel.routeWithArrival) { _, newRouteWithArrival in
            if let arrival = newRouteWithArrival?.arrival {
                let announcement = BusArrivalFormatter.generateArrivalLabel(
                    arrival: arrival,
                    busRoute: viewModel.busRoute,
                    currentEstimatedArrivalTime: viewModel.currentEstimatedArrivalTime
                )
                /// TODO:
                /// - api 호출 주기 짧게 만든 후, 테스트 필요
                /// - 짧은 시간에 공지가 연속 게시되면 이전 멘트를 중단하고 새 멘트를 읽어 "문장이 씹히는" 현상이 발생함
                UIAccessibility.post(notification: .announcement, argument: announcement)
            }
        }
    }
}

// 버스 도착 정보 헬퍼 뷰
struct BusArrivalInfoView: View {
    let routeWithArrival: BusRouteWithArrival
    let currentEstimatedArrivalTime: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "bus.fill")
                    .foregroundColor(.white)
                Text(routeWithArrival.route.routeNumber)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(nil)
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
                .lineLimit(nil)

            Text(L10n.Bus.Arrival.imminent)
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(nil)

            if let arrival = routeWithArrival.arrival {
                Text(BusArrivalFormatter.formatRemainingStops(arrival.remainingStopCount ?? 0))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(nil)
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
            currentEstimatedArrivalTime: currentEstimatedArrivalTime
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
                    .lineLimit(nil)
            }
            .padding(.bottom, 10)

            Text(L10n.Bus.Arrival.noInformation)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .lineLimit(nil)

            Text(L10n.Bus.Arrival.currentBusLocation)
                .font(.title3)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(nil)

            let locationName = location.nodeName ?? String(localized: "common.ui.unknownLocation")
            Text(String(
                format: String(localized: "home.map.near"),
                locationName
            ))
            .font(.title3)
            .foregroundColor(.white.opacity(0.8))
            .lineLimit(nil)
        }
    }
}
