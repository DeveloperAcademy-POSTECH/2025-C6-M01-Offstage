import BusAPI // Assuming BusRoute is defined here
import SwiftUI

struct BusRouteListView: View {
    @Environment(\.dismiss) private var dismiss
    let busRoutes: [BusRoute] // List of bus routes to display
    let onRouteSelected: (BusRoute) -> Void // New closure to pass selected route back

    var body: some View {
        VStack {
            Text("노선 번호를 선택하세요.")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 20)

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(busRoutes, id: \.id) { route in
                        BusRouteButton(route: route, dismiss: dismiss, onRouteSelected: onRouteSelected) // Pass closure
                    }
                }
                .padding(.horizontal)
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
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        .fill(Color.black.opacity(0.3))
                )
                .foregroundColor(.white)
        }
    }
}
