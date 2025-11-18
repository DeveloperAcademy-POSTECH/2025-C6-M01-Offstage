import SwiftUI

struct BusRouteSearchView: View {
    let recognizedText: String

    var body: some View {
        Text("인식된 텍스트: \(recognizedText)")
    }
}
