import SwiftUI

public struct ContentView: View {
    public var body: some View {
        BusDetectionView()
            .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
