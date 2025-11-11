import BusAPI
import SwiftUI

private enum FlowStep {
    case initial
    case stopsFetched([BusStop])
    case stopConfirmed(BusStop)
}

struct MVPTestView: View {
    @StateObject private var viewModel = MVPTestViewModel()
    @State private var step: FlowStep = .initial

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                switch step {
                case .initial:
                    initialStepView
                case let .stopsFetched(stops):
                    stopSelectionStepView(stops: stops)
                case let .stopConfirmed(stop):
                    routeInputStepView(stop: stop)
                }

                if viewModel.resultText != "API 호출 CASE" {
                    responseSection
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("API Flow")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(
            ActivityIndicator(isAnimating: loadingBinding, style: .large)
                .allowsHitTesting(false)
        )
        .onAppear {
            viewModel.onAppear()
            Task {
                if let stops = await viewModel.fetchNearbyStops() {
                    step = .stopsFetched(stops)
                }
            }
        }
    }

    private var initialStepView: some View {
        VStack(spacing: 12) {
            Text("현재 위치를 기반으로 버스 정보를 검색합니다.")
                .font(.headline)
            Button {
                Task {
                    if let stops = await viewModel.fetchNearbyStops() {
                        step = .stopsFetched(stops)
                    }
                }
            } label: {
                Text("주변 정류장 찾기")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .cardStyle()
    }

    private func stopSelectionStepView(stops: [BusStop]) -> some View {
        VStack(spacing: 16) {
            if let closest = stops.first {
                Text("가장 가까운 정류장은 **\(closest.name)** 입니다. 맞습니까?")
                    .font(.headline)
                HStack(spacing: 12) {
                    Button {
                        step = .stopConfirmed(closest)
                    } label: {
                        Text("예")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button {
                        // TODO: Show a list of other stops to choose from
                        step = .initial
                    } label: {
                        Text("아니오")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
            } else {
                Text("주변에 정류장이 없습니다.")
                Button("다시 시도") {
                    step = .initial
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
        .cardStyle()
    }

    private func routeInputStepView(stop: BusStop) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("**\(stop.name)** 정류장을 통과하는 버스 번호를 입력하세요.")
                .font(.headline)

            TextField("e.g., 441", text: $viewModel.routeQuery)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)

            Button {
                viewModel.resetApiDisplay()
                Task {
                    await viewModel.findBusFor(stop: stop, routeQuery: viewModel.routeQuery)
                }
            } label: {
                Text("버스 찾기")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .cardStyle()
    }

    private var responseSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(L10n.Test.Ui.labelResponsePreview, systemImage: "doc.richtext")
                .font(.headline)

            Text(viewModel.resultText)
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.tertiarySystemBackground))
                )

            if let sections = viewModel.displaySections, !sections.isEmpty {
                DTOSectionsView(sections: sections)
            }

            if let rawText = viewModel.rawResponseText {
                Divider()
                RawResponseView(rawText: rawText)
            }
        }
        .cardStyle()
    }

    private var loadingBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isLoading },
            set: { viewModel.isLoading = $0 }
        )
    }
}

// NOTE: DTOSectionsView and RawResponseView are defined in TestView.swift.
// This view relies on them being accessible.

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
