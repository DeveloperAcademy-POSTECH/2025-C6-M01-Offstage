import BusAPI
import SwiftUI

struct BusStopSelectionView: View {
    let currentBusStop: BusStop?
    let onBusStopSelected: (BusStop) -> Void

    var body: some View {
        Text("버스 정류소 선택 뷰")
    }
}
