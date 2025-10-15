import SwiftUI

struct ContentView: View {
    @State private var resultText: String = "API Response will be shown here."
    @State private var isLoading = false

    private let networkingApi = NetworkingAPI()

    // --- Dummy values for testing ---
    private let cityCode = "25" // Daejeon
    private let nodeId = "DJB8001793" // Daejeon Station Stop
    private let routeId = "DJB30300002" // Route 2
    private let stopName = "대전역"
    private let routeNo = "102"
    private let gpsLati = 36.3325
    private let gpsLong = 127.4342

    var body: some View {
        NavigationView {
            VStack {
                // --- Result Display ---
                Text("Result:").font(.headline).padding(.top)
                ScrollView {
                    Text(resultText)
                        .padding()
                }
                .frame(height: 200)
                .background(Color(.systemGray6))
                .cornerRadius(8)

                // --- API Buttons ---
                ScrollView {
                    VStack(spacing: 15) {
                        apiButton(title: "Search Stop", params: ["cityCode": cityCode, "stopName": stopName]) {
                            await performRequest(
                                api: .searchStop(cityCode: cityCode, stopName: stopName),
                                responseType: BusStop.self
                            )
                        }

                        apiButton(title: "Get Arrivals", params: ["cityCode": cityCode, "nodeId": nodeId]) {
                            await performRequest(
                                api: .getArrivals(cityCode: cityCode, nodeId: nodeId),
                                responseType: BusArrivalInfo.self
                            )
                        }

                        apiButton(
                            title: "Get Arrivals for Route",
                            params: ["cityCode": cityCode, "nodeId": nodeId, "routeId": routeId]
                        ) { await performRequest(
                            api: .getArrivalsForRoute(cityCode: cityCode, nodeId: nodeId, routeId: routeId),
                            responseType: BusArrivalInfo.self
                        )
                        }

                        apiButton(title: "Get Route Bus Locations", params: [
                            "cityCode": cityCode,
                            "routeId": routeId,
                        ]) {
                            await performRequest(
                                api: .getRouteBusLocations(cityCode: cityCode, routeId: routeId),
                                responseType: BusLocation.self
                            )
                        }

                        apiButton(
                            title: "Get Stops by GPS",
                            params: ["gpsLati": String(gpsLati), "gpsLong": String(gpsLong)]
                        ) { await performRequest(
                            api: .getStopsByGps(gpsLati: gpsLati, gpsLong: gpsLong),
                            responseType: BusStop.self
                        )
                        }

                        apiButton(title: "Get Stop Routes", params: ["cityCode": cityCode, "nodeId": nodeId]) {
                            await performRequest(
                                api: .getStopRoutes(cityCode: cityCode, nodeId: nodeId),
                                responseType: StationRoute.self
                            )
                        }

                        apiButton(title: "Get Route Info", params: ["cityCode": cityCode, "routeId": routeId]) {
                            await performRequest(
                                api: .getRouteInfo(cityCode: cityCode, routeId: routeId),
                                responseType: BusRoute.self
                            )
                        }

                        apiButton(title: "Search Route", params: ["cityCode": cityCode, "routeNo": routeNo]) {
                            await performRequest(
                                api: .searchRoute(cityCode: cityCode, routeNo: routeNo),
                                responseType: BusRoute.self
                            )
                        }

                        apiButton(title: "Get Route Stops", params: ["cityCode": cityCode, "routeId": routeId]) {
                            await performRequest(
                                api: .getRouteStops(cityCode: cityCode, routeId: routeId),
                                responseType: BusStop.self
                            )
                        }
                    }.padding()
                }
            }
            .navigationTitle("Bus API Test")
            .overlay(ActivityIndicator(isAnimating: $isLoading, style: .large))
        }
    }

    @ViewBuilder
    private func apiButton(title: String, params: [String: String], action: @escaping () async -> Void) -> some View {
        VStack {
            Text(title).font(.headline)
            ForEach(params.sorted(by: <), id: \.key) { key, value in
                Text("\(key): \(value)").font(.caption)
            }
            Button("Execute") {
                Task { await action() }
            }
            .padding(5)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(5)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }

    // Generic request function
    private func performRequest<T: Codable>(api: BusAPI, responseType _: T.Type) async {
        isLoading = true
        resultText = "Loading..."
        do {
            let response: ApiResponse<ItemBody<T>> = try await networkingApi.request(api: api)
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(response)
            resultText = String(data: data, encoding: .utf8) ?? "Failed to encode response"
        } catch {
            resultText = "Error: \(error.localizedDescription)"
        }
        isLoading = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
