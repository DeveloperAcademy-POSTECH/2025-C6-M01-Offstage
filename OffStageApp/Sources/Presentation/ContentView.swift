import SwiftUI

struct ContentView: View {
    @State private var resultText: String = "API Response will be shown here."
    @State private var isLoading = false
    @State private var displayData: Any?
    @State private var isMocking = true

    private var networkingApi: NetworkingAPI {
        NetworkingAPI(isMocking: isMocking)
    }

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
                Toggle("Mock API", isOn: $isMocking)
                    .padding()

                // --- Result Display ---
                Text("Result:").font(.headline).padding(.top)
                ScrollView {
                    if let data = displayData {
                        SampleDataView(data: data)
                    } else {
                        Text(resultText)
                            .padding()
                    }
                }
                .frame(height: 200)
                .background(Color(.systemGray6))
                .cornerRadius(8)

                // --- Buttons ---
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
        Button {
            displayData = nil
            Task { await action() }
        } label: {
            VStack {
                Text(title).font(.headline)
                ForEach(params.sorted(by: <), id: \.key) { key, value in
                    Text("\(key): \(value)").font(.caption)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // Generic request function
    private func performRequest<T: Codable>(api: BusAPI, responseType _: T.Type) async {
        isLoading = true
        resultText = "Loading..."
        displayData = nil
        do {
            let response: ApiResponse<ItemBody<T>> = try await networkingApi.request(api: api)
            if let firstItem = response.response.body?.items.item.first {
                displayData = firstItem
                resultText = ""
            } else {
                resultText = "No items in response"
            }
        } catch let NetworkError.decodingError(error, data) {
            let dataString = String(data: data, encoding: .utf8) ?? "Could not convert data to string"
            resultText = "Decoding Error: \(error.localizedDescription)\n\nRaw Response:\n\(dataString)"
        } catch {
            resultText = "Error: \(error.localizedDescription)"
        }
        isLoading = false
    }
}

struct SampleDataView: View {
    let data: Any

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(String(describing: type(of: data)))
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 5)

            let mirror = Mirror(reflecting: data)
            ForEach(mirror.children.map { $0 }, id: \.label) { child in
                if let label = child.label {
                    HStack {
                        Text("\(label):")
                            .fontWeight(.semibold)
                        Text(String(describing: child.value))
                            .font(.body)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
