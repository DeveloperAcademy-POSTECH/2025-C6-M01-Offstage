import BusAPI
import SwiftUI

enum TestProfile: String, CaseIterable, Identifiable {
    case seoul = "Seoul"
    case nonSeoul = "Pangyo"
    var id: Self { self }
}

struct TestView: View {
    @StateObject private var viewModel = TestViewModel()
    @State private var selectedProfile: TestProfile = .seoul

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Picker(L10n.Test.Ui.pickerProfile, selection: $selectedProfile) {
                        ForEach(TestProfile.allCases) { profile in
                            Text(localizedProfileName(profile)).tag(profile)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedProfile) { newProfile in
                        updateViewModel(for: newProfile)
                    }

//                    Section(
//                        header: Text("API Parameters")
//                    ) {
//                        parameterSection
//                    }

                    Section(
                        header: Text(L10n.Test.Ui.labelApiCall)
                    ) {
                        actionSection
                    }

                    Section(
                        header: Text(L10n.Test.Ui.labelResponsePreview)
                    ) {
                        responseSection
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
            updateViewModel(for: selectedProfile)
        }
    }

    private func updateViewModel(for profile: TestProfile) {
        switch profile {
        case .seoul:
            viewModel.cityCode = "1000"
            viewModel.nodeId = "100000001"
            viewModel.routeId = "100100006"
            viewModel.stopName = "서울역"
            viewModel.routeNo = "100"
            viewModel.gpsLati = "37.555946"
            viewModel.gpsLong = "126.972317"
        case .nonSeoul:
            viewModel.cityCode = "31020"
            viewModel.nodeId = "GGB204000163"
            viewModel.routeId = "GGB204000013"
            viewModel.stopName = "판교"
            viewModel.routeNo = "111"
            viewModel.gpsLati = "37.394726159"
            viewModel.gpsLong = "127.1112090472"
        }
    }

    @ViewBuilder
    private var parameterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            textFieldRow(title: "City Code", text: $viewModel.cityCode)
            textFieldRow(title: "Stop Name", text: $viewModel.stopName)
            textFieldRow(title: "Node ID", text: $viewModel.nodeId)
            textFieldRow(title: "Route ID", text: $viewModel.routeId)
            textFieldRow(title: "Route No", text: $viewModel.routeNo)
            textFieldRow(title: "Latitude", text: $viewModel.gpsLati)
            textFieldRow(title: "Longitude", text: $viewModel.gpsLong)
        }
        .cardStyle()
    }

    @ViewBuilder
    private func textFieldRow(title: String, text: Binding<String>) -> some View {
        HStack {
            Text(title).frame(width: 80, alignment: .leading)
            TextField(title, text: text)
                .textFieldStyle(.roundedBorder)
                .multilineTextAlignment(.trailing)
        }
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

            if selectedProfile == .seoul {
                actionGroup(title: L10n.Test.Ui.titleSeoulSection, actions: seoulAPIActions)
            } else {
                actionGroup(title: L10n.Test.Ui.titleStopSection, actions: stopActions)
                actionGroup(title: L10n.Test.Ui.titleArrivalSection, actions: arrivalActions)
                actionGroup(title: L10n.Test.Ui.titleRouteSection, actions: routeActions)
            }
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

    private func localizedProfileName(_ profile: TestProfile) -> LocalizedStringKey {
        switch profile {
        case .seoul:
            L10n.Test.Ui.profileSeoul
        case .nonSeoul:
            L10n.Test.Ui.profilePangyo
        }
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

    private var routeActions: [APIAction] {
        [
            APIAction(
                title: L10n.Test.Ui.buttonRouteBusLocationsTitle,
                subtitle: L10n.Test.Ui.buttonRouteBusLocationsSubtitle
            ) { await viewModel.getRouteBusLocations() },
            APIAction(
                title: L10n.Test.Ui.buttonRouteInfoTitle,
                subtitle: L10n.Test.Ui.buttonRouteInfoSubtitle
            ) { await viewModel.getRouteInfo() },
            APIAction(
                title: L10n.Test.Ui.buttonSearchRouteTitle,
                subtitle: L10n.Test.Ui.buttonSearchRouteSubtitle
            ) { await viewModel.searchRoute() },
            APIAction(
                title: L10n.Test.Ui.buttonRouteStopsTitle,
                subtitle: L10n.Test.Ui.buttonRouteStopsSubtitle
            ) { await viewModel.getRouteStops() },
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
            APIAction(
                title: "Seoul Route Stations",
                subtitle: "서울 노선 경유 정류장 목록"
            ) { await viewModel.testSeoulRouteStations() },
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
    TestView()
}
