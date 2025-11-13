import BusAPI // Assuming BusRoute is defined here
import SwiftUI

struct BusRouteListView: View {
    @Environment(\.dismiss) private var dismiss
    @AccessibilityFocusState private var isTitleFocused: Bool
    let busRoutes: [BusRoute] // List of bus routes to display
    let onRouteSelected: (BusRoute) -> Void // New closure to pass selected route back

    var body: some View {
        VStack {
            Text(L10n.Home.Sheet.selectBusRoute)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 20)
                .accessibilityAddTraits(.isHeader)
                .accessibilityFocused($isTitleFocused)
                .onAppear {
                    isTitleFocused = true
                }

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(busRoutes, id: \.id) { route in
                        BusRouteButton(route: route, dismiss: dismiss, onRouteSelected: onRouteSelected) // Pass closure
                    }

                    Button(action: {
                        dismiss() // Dismiss the sheet after selection
                    }) {
                        Text(L10n.Home.Sheet.notFound)
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white, lineWidth: 2)
                                    .fill(Color(red: 0.86, green: 0.87, blue: 0.91).opacity(0.05))
                            )
                            .foregroundColor(.white)
                    }
                }
                .padding()
            }
            Spacer()
        }
    }
}

// Helper View for the Bus Route Button
struct BusRouteButton: View {
    let route: BusRoute
    let dismiss: DismissAction // Pass DismissAction directly
    let onRouteSelected: (BusRoute) -> Void // New closure

    var body: some View {
        Button(action: {
            onRouteSelected(route) // Call the closure with the selected route
            print("Selected bus route: \(route.routeNumber)") // Keep existing print
            dismiss() // Dismiss the sheet after selection
        }) {
            Text(route.routeNumber)
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white, lineWidth: 2)
                        .fill(Color(red: 0.86, green: 0.87, blue: 0.91).opacity(0.05))
                )
                .foregroundColor(.white)
        }
    }
}
