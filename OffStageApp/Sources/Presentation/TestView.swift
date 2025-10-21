import BusAPI
import SwiftUI

struct TestView: View {
    @StateObject private var viewModel: TestViewModel

    init(busStopInfo: BusStopInfo) {
        _viewModel = StateObject(wrappedValue: TestViewModel(busStopInfo: busStopInfo))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    actionSection
                    responseSection
                    locationSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("버스 API 테스트")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(
                ActivityIndicator(isAnimating: loadingBinding, style: .large)
                    .allowsHitTesting(false)
            )
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    @ViewBuilder
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            let info = viewModel.busStopInfo

            VStack(alignment: .leading, spacing: 12) {
                infoRow(
                    title: "검색어",
                    value: info.stopName.isEmpty ? "검색어 없음" : info.stopName
                )
                infoRow(
                    title: "위도/경도",
                    value: "\(formattedCoordinate(info.gpsLati))/\(formattedCoordinate(info.gpsLong))"
                )
                infoRow(
                    title: "cityCode",
                    value: "\(info.cityCode)"
                )
                infoRow(
                    title: "노선 ID/노선 번호",
                    value: "\(info.routeId.isEmpty ? "-" : info.routeId)/\(info.routeNo.isEmpty ? "-" : info.routeNo)"
                )
                infoRow(
                    title: "nodeId",
                    value: info.nodeId.isEmpty ? "-" : info.nodeId
                )
            }

            Divider()
        }
        .cardStyle()
    }

    private var responseSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("응답 미리보기", systemImage: "doc.richtext")
                .font(.headline)

            if let sections = viewModel.displaySections, !sections.isEmpty {
                DTOSectionsView(sections: sections)
            } else {
                Text(viewModel.resultText)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.tertiarySystemBackground))
                    )
            }

            if let rawText = viewModel.rawResponseText {
                Divider()
                RawResponseView(rawText: rawText)
            }
        }
        .cardStyle()
    }

    private var actionSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            Label("테스트 API 호출", systemImage: "play.circle.fill")
                .font(.headline)

            actionGroup(title: "정류장 조회", actions: stopActions)
            actionGroup(title: "도착 정보", actions: arrivalActions)
            actionGroup(title: "노선 정보", actions: routeActions)
        }
        .cardStyle()
    }

    @ViewBuilder
    private func actionGroup(title: String, actions: [APIAction]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            LazyVGrid(columns: gridColumns(for: actions.count), spacing: 12) {
                ForEach(actions) { action in
                    apiButton(for: action)
                }
            }
        }
    }

    @ViewBuilder
    private func apiButton(for action: APIAction) -> some View {
        Button {
            viewModel.resetApiDisplay()
            Task { await action.task() }
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text(action.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(action.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 96, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.tertiarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color(.separator).opacity(0.5))
            )
        }
        .buttonStyle(.plain)
    }

    private var loadingBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isLoading },
            set: { viewModel.isLoading = $0 }
        )
    }

    private var stopActions: [APIAction] {
        [
            APIAction(
                title: "정류장 키워드 검색",
                subtitle: "도시 코드와 정류장 이름으로 조회",
            ) { await viewModel.searchStop() },
            APIAction(
                title: "현위치 주변 정류장",
                subtitle: "현재 좌표 기준으로 반경 검색",
            ) { await viewModel.getStopsByGPS() },
            APIAction(
                title: "정류장을 지나는 노선",
                subtitle: "선택한 정류장을 통과하는 노선 목록",
            ) { await viewModel.getStopRoutes() },
        ]
    }

    private var arrivalActions: [APIAction] {
        [
            APIAction(
                title: "정류장 도착 정보",
                subtitle: "정류장 기준 전체 도착 예정 정보",
            ) { await viewModel.getArrivals() },
            APIAction(
                title: "특정 노선 도착 정보",
                subtitle: "정류장 + 노선 조합으로 도착 조회",
            ) { await viewModel.getArrivalsForRoute() },
        ]
    }

    private var routeActions: [APIAction] {
        [
            APIAction(
                title: "차량 실시간 위치",
                subtitle: "선택한 노선의 차량 위치 추적",
            ) { await viewModel.getRouteBusLocations() },
            APIAction(
                title: "노선 기본 정보",
                subtitle: "첫/막차 시간 등 노선 상세 확인",
            ) { await viewModel.getRouteInfo() },
            APIAction(
                title: "노선 번호 검색",
                subtitle: "노선 번호 키워드로 노선 찾기",
            ) { await viewModel.searchRoute() },
            APIAction(
                title: "노선 경유 정류장",
                subtitle: "노선이 지나가는 정류장 순서 확인",
            ) { await viewModel.getRouteStops() },
        ]
    }

    private func gridColumns(for count: Int) -> [GridItem] {
        let columnCount = switch count {
        case ..<2:
            1
        case 2:
            2
        case 3:
            3
        default:
            3
        }

        return Array(repeating: GridItem(.flexible(), spacing: 12), count: columnCount)
    }

    @ViewBuilder
    private func infoRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)
        }
    }

    private func formattedCoordinate(_ value: Double) -> String {
        String(format: "%.5f", value)
    }
}

struct DTOSectionsView: View {
    let sections: [DTOSection]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(sections) { section in
                VStack(alignment: .leading, spacing: 8) {
                    Text(section.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(section.items) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(item.value)
                                    .font(.system(.footnote, design: .monospaced))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            if item.id != section.items.last?.id {
                                Divider()
                                    .opacity(0.2)
                            }
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(.tertiarySystemBackground))
                    )
                }
            }
        }
    }
}

struct RawResponseView: View {
    let rawText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("원본 응답(JSON)")
                .font(.subheadline)
                .fontWeight(.semibold)

            ScrollView {
                Text(rawText)
                    .font(.system(.caption, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            }
            .frame(minHeight: 80, maxHeight: 220)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(.tertiarySystemBackground))
            )
        }
    }
}

private struct APIAction: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let task: () async -> Void
}

private extension View {
    func cardStyle() -> some View {
        padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color(.separator).opacity(0.35))
            )
    }
}

#Preview {
    TestView(busStopInfo: .init(
        cityCode: 25,
        nodeId: "",
        routeId: "",
        stopName: "",
        routeNo: "",
        gpsLati: 0,
        gpsLong: 0
    ))
}
