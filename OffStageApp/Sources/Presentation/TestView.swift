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
                    Section(
                        header: Text(L10n.Test.A11y.headerDeviceInfo)
                            .accessibilityAddTraits(.isHeader)
                    ) {
                        actionSection
                        responseSection
                    }

                    Section(
                        header: Text(L10n.Test.A11y.headerBusInfo)
                            .accessibilityAddTraits(.isHeader)
                    ) {
                        locationSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(L10n.Test.Ui.titleNavigation)
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
                if info.stopName.isEmpty {
                    infoRow(
                        title: L10n.Test.Ui.labelSearchTerm,
                        value: L10n.Test.Ui.placeholderNoSearchTerm
                    )
                } else {
                    infoRow(
                        title: L10n.Test.Ui.labelSearchTerm,
                        value: info.stopName
                    )
                }
                infoRow(
                    title: L10n.Test.Ui.labelCoordinates,
                    value: "\(formattedCoordinate(info.gpsLati))/\(formattedCoordinate(info.gpsLong))"
                )
                infoRow(
                    title: L10n.Test.Ui.labelCityCode,
                    value: "\(info.cityCode)"
                )
                infoRow(
                    title: L10n.Test.Ui.labelRoute,
                    value: "\(info.routeId.isEmpty ? "-" : info.routeId)/\(info.routeNo.isEmpty ? "-" : info.routeNo)"
                )
                infoRow(
                    title: L10n.Test.Ui.labelNodeId,
                    value: info.nodeId.isEmpty ? "-" : info.nodeId
                )
            }

            Divider()
        }
        .cardStyle()
    }

    private var responseSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(L10n.Test.Ui.labelResponsePreview, systemImage: "doc.richtext")
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
            Label(L10n.Test.Ui.labelApiCall, systemImage: "play.circle.fill")
                .font(.headline)

            actionGroup(title: L10n.Test.Ui.titleStopSection, actions: stopActions)
            actionGroup(title: L10n.Test.Ui.titleArrivalSection, actions: arrivalActions)

            // MARK: - Seoul API Tests

            actionGroup(title: "Seoul API Tests", actions: seoulAPIActions)
        }
        .cardStyle()
    }

    @ViewBuilder
    private func actionGroup(title: LocalizedStringKey, actions: [APIAction]) -> some View {
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
                title: L10n.Test.Ui.buttonSearchStopTitle,
                subtitle: L10n.Test.Ui.buttonSearchStopSubtitle
            ) { await viewModel.searchStop() },
            APIAction(
                title: L10n.Test.Ui.buttonStopsByGpsTitle,
                subtitle: L10n.Test.Ui.buttonStopsByGpsSubtitle
            ) { await viewModel.getStopsByGPS() },
            APIAction(
                title: L10n.Test.Ui.buttonStopRoutesTitle,
                subtitle: L10n.Test.Ui.buttonStopRoutesSubtitle
            ) { await viewModel.getStopRoutes() },
        ]
    }

    private var arrivalActions: [APIAction] {
        [
            APIAction(
                title: L10n.Test.Ui.buttonArrivalsTitle,
                subtitle: L10n.Test.Ui.buttonArrivalsSubtitle
            ) { await viewModel.getArrivals() },
            APIAction(
                title: L10n.Test.Ui.buttonArrivalsForRouteTitle,
                subtitle: L10n.Test.Ui.buttonArrivalsForRouteSubtitle
            ) { await viewModel.getArrivalsForRoute() },
        ]
    }

    private var seoulAPIActions: [APIAction] {
        [
            APIAction(
                title: "Seoul GPS Search",
                subtitle: "현재 GPS로 서울 정류장 검색"
            ) { await viewModel.testSeoulGpsSearch() },
            APIAction(
                title: "Seoul Keyword Search",
                subtitle: "키워드로 서울 정류장 검색 (서울역)"
            ) { await viewModel.testSeoulKeywordSearch() },
            APIAction(
                title: "Seoul Stop Detail",
                subtitle: "서울 정류소 상세 정보 (도착, 노선)"
            ) { await viewModel.testSeoulStopDetail() },
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
    private func infoRow(title: LocalizedStringKey, value: String) -> some View {
        HStack { // Changed from VStack to HStack for accessibility grouping
            Text(title) // 시각적 UI
            Spacer()
            Text(value) // 시각적 UI
        }
        // --- ⬇️ A11y 3단계 전략 적용 ⬇️ ---
        .accessibilityElement(children: .ignore) // 1. [Element] 개별 Text 무시
        .accessibilityLabel(title) // 2. [Label] "제목"
        .accessibilityValue(Text(value)) // 3. [Value] "값"
    }

    @ViewBuilder
    private func infoRow(title: LocalizedStringKey, value: LocalizedStringKey) -> some View {
        HStack { // Changed from VStack to HStack for accessibility grouping
            Text(title)
            Spacer()
            Text(value)
        }
        // --- ⬇️ A11y 3단계 전략 적용 ⬇️ ---
        .accessibilityElement(children: .ignore) // 1. [Element]
        .accessibilityLabel(title) // 2. [Label]
        .accessibilityValue(Text(value)) // 3. [Value]
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
            Text(L10n.Test.Ui.labelRawResponse)
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
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
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
