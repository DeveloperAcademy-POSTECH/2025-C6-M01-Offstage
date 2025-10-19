import BusAPI
import SwiftUI

struct TestView: View {
    @StateObject private var viewModel: TestViewModel

    init(busStopInfo: BusStopInfo) {
        _viewModel = StateObject(wrappedValue: TestViewModel(busStopInfo: busStopInfo))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                locationSection

                Divider()

                apiSection
            }
            .padding()
            .navigationTitle("Sprint 1")
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
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Text("Latitude: \(viewModel.busStopInfo.gpsLati)")
                Text("Longitude: \(viewModel.busStopInfo.gpsLong)")
            }
            .font(.body)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    @ViewBuilder
    private var apiSection: some View {
        ScrollView { VStack(alignment: .leading, spacing: 16) {
            Toggle("Mock API", isOn: $viewModel.isMocking)
            ScrollView {
                if let data = viewModel.displayData {
                    SampleDataView(data: data)
                } else {
                    Text(viewModel.resultText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
            }
            .frame(height: 200)
            .background(Color(.systemGray6))
            .cornerRadius(8)

            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                ], spacing: 15) {
                    apiButton(title: "Search Stop") {
                        await viewModel.searchStop()
                    }

                    apiButton(title: "Get Arrivals") {
                        await viewModel.getArrivals()
                    }

                    apiButton(title: "Get Arrivals for Route") {
                        await viewModel.getArrivalsForRoute()
                    }

                    apiButton(title: "Get Route Bus Locations") {
                        await viewModel.getRouteBusLocations()
                    }

                    apiButton(title: "Get Stops by GPS") {
                        await viewModel.getStopsByGPS()
                    }

                    apiButton(title: "Get Stop Routes") {
                        await viewModel.getStopRoutes()
                    }

                    apiButton(title: "Get Route Info") {
                        await viewModel.getRouteInfo()
                    }

                    apiButton(title: "Search Route") {
                        await viewModel.searchRoute()
                    }

                    apiButton(title: "Get Route Stops") {
                        await viewModel.getRouteStops()
                    }
                }
                .padding(.vertical, 4)
            }
        }}
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func apiButton(title: String, action: @escaping () async -> Void) -> some View {
        Button {
            viewModel.resetApiDisplay()
            Task { await action() }
        } label: {
            VStack {
                Text(title).font(.headline)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: 100)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var loadingBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isLoading },
            set: { viewModel.isLoading = $0 }
        )
    }
}

struct SampleDataView: View {
    let data: Any

    var body: some View {
        ScrollView {
            Text(String(describing: data))
                .font(.system(.caption, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
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
